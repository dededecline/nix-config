#!/usr/bin/env bash
PERCENT=$(pmset -g batt | grep -Eo '[[:digit:]]+%' | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power' || echo "")

sketchybar --set "${NAME}" label="${PERCENT}${CHARGING:++}"
