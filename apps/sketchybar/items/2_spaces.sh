#!/usr/bin/env bash

set -x
set -e

declare -A SPACE_ICONS=(
  ["1"]="$HOME_ICON"
  ["2"]="$BROWSER_ICON"
  ["3"]="$DISCORD_ICON"
  ["5"]="$OBSIDIAN_ICON"
  ["8"]="$MAIL_ICON" 
  ["T"]="$TERMINAL_ICON"
)

sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_workspace_monitor_change

FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused)"

draw_space_icons() {
  display=$1
  echo "Drawing space icons for ${display}"

  for sid in $(aerospace list-workspaces --monitor "$display"); do
    echo "trying to draw ${sid}"

    if [[ ! -v SPACE_ICONS[$sid] ]]; then 
      continue
    fi

    if [[ -z "${SPACE_ICONS[$sid]}" ]]; then
      echo "skipping ${sid}"
    else  
      echo "drawing ${sid}"

      workspace=(
        label.drawing=off
        display="${display}"
        icon="${SPACE_ICONS[$sid]}" 
        icon.highlight_color="$ACTIVE_WORKSPACE_COLOR"
        icon.padding_left=8
        icon.padding_right=8
        icon.background.drawing=off
        click_script="aerospace workspace ${sid}" 
        script="plugin_aerospace ${sid}"
      ) 

      sketchybar --add item "space.${sid}" left \
        --subscribe "space.${sid}" aerospace_workspace_change \
        --subscribe "space.${sid}" aerospace_workspace_monitor_change \
        --set "space.${sid}" "${workspace[@]}" 

      FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE" NAME="space.${sid}" plugin_aerospace "${sid}" &
    fi

  done
}

draw_space_icons 1
draw_space_icons 2

wrapper=(
  background.color="$SPACES_WRAPPER_BACKGROUND"
  background.border_color="$SPACES_ITEM_BACKGROUND"
  background.border_width=2
  background.drawing=on
)

separator=(
  icon=􀆊
  icon.font="$ICON_FONT:Heavy:16.0"
  padding_left=15
  padding_right=15
  label.drawing=off
  associated_display=active
  icon.color="$ICON_COLOR"
)

sketchybar --add bracket wrapper '/space\..*/' \
  --set wrapper "${wrapper[@]}"        

sketchybar --add item separator left \
  --set separator "${separator[@]}"
