#!/usr/bin/env bash
#
# Display Mode Optimizer
# 
# This script automatically sets all connected displays to the optimal mode:
# - Finds the highest resolution with the highest refresh rate for each display
# - Ensures scaling is enabled for better text clarity
# - Only changes modes if they're not already set
# - Applies all changes in a single command to avoid flickering

# Path to displayplacer binary
DISPLAYPLACER="/opt/homebrew/bin/displayplacer"

# Define display origins - position index corresponds to display order
DISPLAY_ORIGINS=("(0,0)" "(-3360,-173)")

# Get displayplacer output once to avoid multiple calls
DISPLAY_INFO=$($DISPLAYPLACER list)

# Get all display IDs
DISPLAY_IDS=$(echo "$DISPLAY_INFO" | grep "Persistent screen id:" | awk '{print $4}')

# If we couldn't get any display IDs, exit
if [ -z "$DISPLAY_IDS" ]; then
  echo "Error: Could not find any display IDs"
  exit 1
fi

# Show current settings
echo "Current display settings:"
echo "$DISPLAY_INFO" | grep -E "Persistent screen id:|Resolution:|Hertz:|Color Depth:|Scaling:|Origin:"

echo "Analyzing display modes..."

# Process all displays and build the final command
FINAL_CMD="$DISPLAYPLACER"
NEEDS_CHANGE=0
DISPLAY_CONFIGS=""

# Process each display
DISPLAY_INDEX=0
while IFS= read -r display_id; do
  echo "Processing display: $display_id"
  
  # Get the origin for this display
  if [ $DISPLAY_INDEX -lt ${#DISPLAY_ORIGINS[@]} ]; then
    DISPLAY_ORIGIN="${DISPLAY_ORIGINS[$DISPLAY_INDEX]}"
  else
    DISPLAY_ORIGIN="(0,0)"
  fi
  
  # Get current display settings
  CURRENT_RES=$(echo "$DISPLAY_INFO" | awk -v id="$display_id" '
    BEGIN { found=0; res=""; }
    /Persistent screen id:/ { if ($4 == id) found=1; else found=0; }
    found && /Resolution:/ { match($0, /[0-9]+x[0-9]+/); res=substr($0, RSTART, RLENGTH); }
    END { print res; }
  ')
  CURRENT_HZ=$(echo "$DISPLAY_INFO" | awk -v id="$display_id" '
    BEGIN { found=0; hz=0; }
    /Persistent screen id:/ { if ($4 == id) found=1; else found=0; }
    found && /Hertz:/ { match($0, /[0-9]+/); hz=substr($0, RSTART, RLENGTH); }
    END { print hz; }
  ')
  CURRENT_ORIGIN=$(echo "$DISPLAY_INFO" | awk -v id="$display_id" '
    BEGIN { found=0; origin=""; }
    /Persistent screen id:/ { if ($4 == id) found=1; else found=0; }
    found && /Origin:/ { match($0, /\([0-9-]+,[0-9-]+\)/); if (RSTART > 0) origin=substr($0, RSTART, RLENGTH); }
    END { print origin; }
  ')
  
  if [ -z "$CURRENT_RES" ] || [ -z "$CURRENT_HZ" ]; then
    echo "Warning: Could not determine current settings for display $display_id"
    continue
  fi
  
  # Split current resolution
  IFS='x' read -r CURRENT_WIDTH CURRENT_HEIGHT <<< "$CURRENT_RES"
  CURRENT_WIDTH=${CURRENT_WIDTH:-0}
  CURRENT_HEIGHT=${CURRENT_HEIGHT:-0}
  CURRENT_HZ=${CURRENT_HZ:-0}
  
  # Find optimal mode for this display
  BEST_MODE=$(echo "$DISPLAY_INFO" | awk -v id="$display_id" '
    BEGIN { 
      found=0; best_width=0; best_height=0; best_hz=0; best_res=""; found_optimal=0;
    }
    /Persistent screen id:/ { if ($4 == id) found=1; else found=0; }
    found && /mode/ && /scaling:on/ {
      if (match($0, /res:[0-9]+x[0-9]+/)) {
        res_str = substr($0, RSTART, RLENGTH);
        gsub(/res:/, "", res_str);
        split(res_str, res_parts, "x");
        width = res_parts[1] + 0;
        height = res_parts[2] + 0;
        if (match($0, /hz:[0-9]+/)) {
          hz_str = substr($0, RSTART, RLENGTH);
          gsub(/hz:/, "", hz_str);
          hz = hz_str + 0;
          better_mode = 0;
          if (width > best_width) {
            better_mode = 1;
          } else if (width == best_width && height > best_height) {
            better_mode = 1;
          } else if (width == best_width && height == best_height && hz > best_hz) {
            better_mode = 1;
          }
          if (better_mode) {
            best_width = width;
            best_height = height;
            best_hz = hz;
            best_res = res_str;
            found_optimal = 1;
          }
        }
      }
    }
    END {
      if (found_optimal) {
        print best_width "," best_height "," best_hz "," best_res;
      }
    }
  ')
  
  if [ -z "$BEST_MODE" ]; then
    echo "Display $display_id: No suitable modes found"
    continue
  fi
  
  # Split best mode info
  IFS=',' read -r BEST_WIDTH BEST_HEIGHT BEST_HZ BEST_RES <<< "$BEST_MODE"
  
  # Check if we need to change the mode or origin
  echo "Display $display_id: Optimal mode ${BEST_WIDTH}x${BEST_HEIGHT} @ ${BEST_HZ}Hz"
  
  CHANGE_NEEDED=0
  CHANGE_REASONS=""
  
  # Check if mode needs to change
  if [ "$CURRENT_WIDTH" -ne "$BEST_WIDTH" ] || [ "$CURRENT_HEIGHT" -ne "$BEST_HEIGHT" ] || [ "$CURRENT_HZ" -ne "$BEST_HZ" ]; then
    CHANGE_NEEDED=1
    CHANGE_REASONS="$CHANGE_REASONS\n- Will change from ${CURRENT_WIDTH}x${CURRENT_HEIGHT}@${CURRENT_HZ}Hz to ${BEST_WIDTH}x${BEST_HEIGHT}@${BEST_HZ}Hz"
  else
    echo "- Already using optimal mode"
  fi
  
  # Check if origin needs to change
  if [ "$CURRENT_ORIGIN" != "$DISPLAY_ORIGIN" ]; then
    CHANGE_NEEDED=1
    CHANGE_REASONS="$CHANGE_REASONS\n- Will change origin from ${CURRENT_ORIGIN:-'(unknown)'} to $DISPLAY_ORIGIN"
  else
    echo "- Already at correct position"
  fi
  
  # Add to command if changes needed
  if [ $CHANGE_NEEDED -eq 1 ]; then
    if [ -n "$CHANGE_REASONS" ]; then
      echo -e "Changes needed:$CHANGE_REASONS"
    fi
    
    if [ -n "$DISPLAY_CONFIGS" ]; then
      DISPLAY_CONFIGS="$DISPLAY_CONFIGS "
    fi
    DISPLAY_CONFIGS="$DISPLAY_CONFIGS\"id:$display_id res:$BEST_RES hz:$BEST_HZ color_depth:8 scaling:on origin:$DISPLAY_ORIGIN degree:0\""
    NEEDS_CHANGE=1
  fi
  
  # Increment display index
  DISPLAY_INDEX=$((DISPLAY_INDEX + 1))
done <<< "$DISPLAY_IDS"

# Apply changes if needed
if [ $NEEDS_CHANGE -eq 1 ]; then
  echo "Applying display changes..."
  eval "$FINAL_CMD $DISPLAY_CONFIGS"
  echo "Display modes updated successfully."
else
  echo "All displays are already using optimal modes and positions."
fi
