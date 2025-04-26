#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
  ICON=$(date '+%Z')
  LABEL=$(date '+%H:%M %D')
else
  ICON=$(date -u '+%Z')
  LABEL=$(date -u '+%H:%M %D')
fi


sketchybar --set "$NAME" label="${LABEL:-error}" icon="${ICON:-$NAME}"
