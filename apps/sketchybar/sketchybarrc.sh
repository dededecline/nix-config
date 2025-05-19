#!/usr/bin/env bash

set -x

PADDINGS=3
bar=(
  height="$BAR_HEIGHT"
  position=top
  padding_left=16
  padding_right=16
  margin="$BAR_MARGIN"
  y_offset="$BAR_TOP_OFFSET"
  color="0x40$(BAR_COLOR)"
  corner_radius="$BAR_CORNER_RADIUS"
  sticky=off
  blur_radius=2
  font_smoothing=on
)

default=(
  icon.font="$ICON_FONT:Regular:18"
  icon.color="0xff$(ICON_COLOR)"
  icon.highlight_color="0xff$($ICON_HIGHLIGHT_COLOR)"
  icon.padding_left="$PADDINGS"
  icon.padding_right="$PADDINGS"

  label.font="$FONT:Thin:16.0"
  label.color="0xff$($LABEL_COLOR)"
  label.highlight_color="0xff$($LABEL_HIGHLIGHT_COLOR)"
  label.padding_left="$PADDINGS"
  label.padding_right="$PADDINGS"
  padding_right="$PADDINGS"
  padding_left="$PADDINGS"
  background.height=30
  background.corner_radius=9

  popup.background.border_width=POPUP_BORDER_WIDTH 
  popup.background.corner_radius=POPUP_CORNER_RADIUS 
  popup.background.border_color="0x44$(POPUP_BORDER_COLOR)"
  popup.background.color="0xff$(POPUP_BACKGROUND_COLOR)"
  popup.blur_radius=20
  popup.background.shadow.drawing=on

  updates=when_shown
)

sketchybar \
  --bar "${bar[@]}" \
  --default "${default[@]}"

sketchybar --update

echo "sketchybar configuation loaded.."
