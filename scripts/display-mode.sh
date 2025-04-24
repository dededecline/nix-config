#!/bin/bash
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

# Get all display IDs
DISPLAY_IDS=$($DISPLAYPLACER list | grep "Persistent screen id:" | awk '{print $4}')

# If we couldn't get any display IDs, exit
if [ -z "$DISPLAY_IDS" ]; then
  echo "Error: Could not find any display IDs"
  exit 1
fi

# Get current display information
CURRENT_INFO=$($DISPLAYPLACER list | grep -E "Persistent screen id:|Resolution:|Hertz:|Color Depth:|Scaling:")
echo "Current display settings:"
echo "$CURRENT_INFO"

echo "Analyzing display modes..."

# Process all displays and build the final command
FINAL_CMD="$DISPLAYPLACER"
NEEDS_CHANGE=0
DISPLAY_CONFIGS=""

# Process each display
while IFS= read -r display_id; do
  echo "Processing display: $display_id"
  
  # Create a temporary file for the awk script
  AWK_SCRIPT=$(mktemp)
  
  cat > "$AWK_SCRIPT" << 'EOF'
BEGIN {
  best_width = 0;
  best_height = 0;
  best_hz = 0;
  found_optimal = 0;
  current_display = 0;
  current_width = 0;
  current_height = 0;
  current_hz = 0;
}

# Track which display we're processing
/Persistent screen id:/ {
  if ($4 == display_id) {
    current_display = 1;
  } else {
    current_display = 0;
  }
}

# Get current display settings
current_display && /Resolution:/ {
  if (match($0, /[0-9]+x[0-9]+/)) {
    res_str = substr($0, RSTART, RLENGTH);
    split(res_str, res_parts, "x");
    current_width = res_parts[1] + 0;
    current_height = res_parts[2] + 0;
  }
}

current_display && /Hertz:/ {
  if (match($0, /[0-9]+/)) {
    current_hz = substr($0, RSTART, RLENGTH) + 0;
  }
}

# Only process modes for the current display
current_display && /mode/ && /scaling:on/ {
  # Extract the resolution (format: res:1234x5678)
  if (match($0, /res:[0-9]+x[0-9]+/)) {
    res_str = substr($0, RSTART, RLENGTH);
    gsub(/res:/, "", res_str);
    split(res_str, res_parts, "x");
    width = res_parts[1] + 0;
    height = res_parts[2] + 0;
    
    # Extract the refresh rate (format: hz:120)
    if (match($0, /hz:[0-9]+/)) {
      hz_str = substr($0, RSTART, RLENGTH);
      gsub(/hz:/, "", hz_str);
      hz = hz_str + 0;
      
      # Determine if this is a better mode
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
    printf("Display %s: Optimal mode %dx%d @ %dHz\n", display_id, best_width, best_height, best_hz);
    
    # Compare with current settings
    if (current_width != best_width || current_height != best_height || current_hz != best_hz) {
      printf("CHANGE:%s:%s:%d\n", display_id, best_res, best_hz);
      printf("Display %s: Will change from %dx%d@%dHz to %dx%d@%dHz\n", 
             display_id, current_width, current_height, current_hz,
             best_width, best_height, best_hz);
    } else {
      printf("Display %s: Already using optimal mode\n", display_id);
    }
  } else {
    printf("Display %s: No suitable modes found\n", display_id);
  }
}
EOF

  # Create a temporary file for the output
  OUTPUT_FILE=$(mktemp)
  
  # Parse display modes and find the optimal one for this display
  $DISPLAYPLACER list | awk -v display_id="$display_id" -f "$AWK_SCRIPT" > "$OUTPUT_FILE"
  
  # Process the output file
  while IFS= read -r line; do
    if [[ $line == CHANGE:* ]]; then
      # Extract display configuration from the CHANGE line
      IFS=':' read -r _ id res hz <<< "$line"
      if [ -n "$DISPLAY_CONFIGS" ]; then
        DISPLAY_CONFIGS="$DISPLAY_CONFIGS "
      fi
      DISPLAY_CONFIGS="$DISPLAY_CONFIGS\"id:$id res:$res hz:$hz color_depth:8 scaling:on origin:(0,0) degree:0\""
      NEEDS_CHANGE=1
    else
      # Print status messages
      echo "$line"
    fi
  done < "$OUTPUT_FILE"
  
  # Clean up temporary files
  rm -f "$AWK_SCRIPT" "$OUTPUT_FILE"
done <<< "$DISPLAY_IDS"

# Apply changes if needed
if [ $NEEDS_CHANGE -eq 1 ]; then
  echo "Applying display changes..."
  eval "$FINAL_CMD $DISPLAY_CONFIGS"
  echo "Display modes updated successfully."
else
  echo "All displays are already using optimal modes."
fi
