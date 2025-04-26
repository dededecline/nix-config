#!/usr/bin/env bash
set -x

bar=(
  height=38
  position=top
  padding_left=16
  padding_right=16
  color="0x40${THEME_BASE}"
  sticky=off
  blur_radius=2
  font_smoothing=on
)

default=(
  icon.font="notomono Nerd Font Propo:Thin:12.0"
  icon.color="0xff${THEME_TEXT}"
  icon.highlight_color="0xff${THEME_PINK}"

  label.font="NotoMono Nerd Font Propo:Thin:14.0"
  label.color="0xff${THEME_TEXT}"
  label.highlight_color="0xff${THEME_PINK}"

  background.padding_left=4
  background.padding_right=4
  label.padding_left=4
  label.padding_right=4
  icon.padding_left=4
  icon.padding_right=4
  padding_left=4
  padding_right=4

  updates=when_shown
)

sketchybar \
  --bar "${bar[@]}" \
  --default "${default[@]}"

sketchybar --add event aerospace_workspace_change

FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused)"
for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item "space.${sid}" left \
        --subscribe "space.${sid}" aerospace_workspace_change \
        --set "space.${sid}" \
        background.color="0xff${THEME_SURFACE1}" \
        background.border_color="0x44${THEME_PINK}" \
        background.corner_radius=5 \
        background.height=20 \
        background.drawing=on \
        icon.color="0xff${THEME_TEXT}" \
        icon.font="sketchybar-app-font:Regular:8.0" \
        label="${sid}" \
        label.drawing=on \
        label.align=center \
        label.width=20 \
        label.padding_right=12 \
        label.y_offset=-1 \
        drawing=on \
        update_freq=5 \
        click_script="aerospace workspace ${sid}" \
        script="aerospace_plugin ${sid}"
    # Trigger initial update for this space
    FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE" NAME="space.${sid}" aerospace_plugin "${sid}" &
done

sketchybar \
  --add bracket spaces '/space\..*/' \
  --set spaces \
  padding_left=2 \
  padding_right=2

sketchybar \
  --add item app_name left \
  --set app_name \
  icon=APP \
  script="app_name_plugin" \
  --subscribe app_name front_app_switched

sketchybar \
  --add item battery right \
  --set battery \
  update_freq=15 \
  icon=BAT \
  script="battery_plugin"

sketchybar \
  --add item clock right \
  --set clock \
  update_freq=15 \
  script="clock_plugin 2>/tmp/sbar"

sketchybar --update
