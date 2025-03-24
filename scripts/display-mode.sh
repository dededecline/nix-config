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

# Run displayplacer and pipe to awk for processing
$DISPLAYPLACER list | \
  awk '
    # Process lines containing mode information with scaling enabled
    /mode/ && /scaling:on/ { 
      # Extract resolution
      res = $2
      sub(/res:/, "", res)
      
      # Split resolution into width and height
      split(res, dims, "x")
      width = dims[1]
      height = dims[2]
      
      # Extract refresh rate
      sub(/hz:/, "", $3)
      hz = $3
      
      # Check if this is the current mode
      is_current = (index($0, "current") > 0)
      
      # Store the current line and display ID
      line = $0
      id_line = prev_line 
    }
    
    # Store each line for reference in the next iteration
    { 
      prev_line = $0 
    }
    
    # After processing all lines, apply the optimal mode if needed
    END { 
      if (!is_current) {
        # Build the displayplacer command with proper formatting
        cmd = sprintf("%s \"id:%s %s hz:%s color_depth:8 scaling:on origin:(0,0) degree:0\"", 
                     "'$DISPLAYPLACER'", id_line, res, hz)
        
        # Execute the command
        system(cmd)
      }
    }
  ' | \
  # Sort by resolution and refresh rate (highest first)
  sort -t: -k2,2nr -k3,3nr -k4,4nr | \
  # Take only the top result (optimal mode)
  head -1
