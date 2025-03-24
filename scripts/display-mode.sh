#!/bin/bash
#
# Display Mode Optimizer
# 
# This script automatically sets the display to the optimal mode:
# - Finds the highest resolution with the highest refresh rate
# - Ensures scaling is enabled for better text clarity
# - Only changes the mode if it's not already set

# Path to displayplacer binary
DISPLAYPLACER="/opt/homebrew/bin/displayplacer"

# Get the display ID information first
DISPLAY_ID=$($DISPLAYPLACER list | grep "Persistent screen id:" | head -1 | awk '{print $4}')

# If we couldn't get a display ID, exit
if [ -z "$DISPLAY_ID" ]; then
  echo "Error: Could not find display ID"
  exit 1
fi

echo "Found display ID: $DISPLAY_ID"

# Get current resolution information
CURRENT_INFO=$($DISPLAYPLACER list | grep -E "Resolution:|Hertz:|Color Depth:|Scaling:")
echo "Current display settings:"
echo "$CURRENT_INFO"

echo "Analyzing display modes..."

# Parse display modes and find the optimal one
$DISPLAYPLACER list | awk -v display_id="$DISPLAY_ID" '
  BEGIN {
    best_width = 0;
    best_height = 0;
    best_hz = 0;
    found_optimal = 0;
  }
  
  # Check for lines containing both "mode" and "scaling:on"
  /mode/ && /scaling:on/ {
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
        
        # Check if this is the current mode
        is_current = (index($0, "current") > 0);
        
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
          best_current = is_current;
          best_res = res_str;
          found_optimal = 1;
        }
      }
    }
  }
  
  END {
    if (found_optimal) {
      printf("Optimal mode: %dx%d @ %dHz\n", best_width, best_height, best_hz);
      
      if (!best_current) {
        cmd = sprintf("%s \"id:%s res:%s hz:%d color_depth:8 scaling:on origin:(0,0) degree:0\"", 
                    "'"$DISPLAYPLACER"'", display_id, best_res, best_hz);
        printf("Changing display mode...\n");
        system(cmd);
        printf("Display mode updated successfully.\n");
      } else {
        printf("Already using optimal mode - no change needed.\n");
      }
    } else {
      printf("No suitable display modes found.\n");
    }
  }
'
