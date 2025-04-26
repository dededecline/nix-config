#!/usr/bin/env bash

SID=$1
# If NAME isn't set, construct it from SID
if [ -z "${NAME}" ]; then
  NAME="space.${SID}"
fi

FOCUSED=''
if [ -n "${SID}" ] && [ "${SID}" = "${FOCUSED_WORKSPACE}" ]; then
  FOCUSED=1
  sketchybar --set "${NAME}" label.highlight=on background.drawing=on
elif [ -n "${FOCUSED_WORKSPACE}" ]; then
  sketchybar --set "${NAME}" label.highlight=off
fi

# Always show workspace items, but style them differently
if [ -n "${FOCUSED}" ] || [[ -n $(aerospace list-windows --workspace "${SID}") ]]; then
  # Workspace is focused or has windows - make it more visible
  sketchybar --set "${NAME}" label.color=0xffcdd6f4 drawing=on background.border_width=2
else
  # Empty workspace - still visible but dimmed
  sketchybar --set "${NAME}" label.color=0xff6c7086 drawing=on background.border_width=0
fi
