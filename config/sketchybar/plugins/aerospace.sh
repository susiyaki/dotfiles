#!/bin/bash

# This script is called by SketchyBar when workspace changes
# $1 is the workspace number passed from sketchybarrc
# $FOCUSED_WORKSPACE is set by AeroSpace via exec-on-workspace-change

WORKSPACE_ID="$1"

# Get windows in this workspace
WINDOWS=$(aerospace list-windows --workspace "$WORKSPACE_ID" 2>/dev/null)
WINDOW_COUNT=$(echo "$WINDOWS" | grep -v '^$' | wc -l | tr -d ' ')

# Get the currently focused workspace
# If FOCUSED_WORKSPACE is not set (periodic update), get it directly
if [ -z "$FOCUSED_WORKSPACE" ]; then
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
fi

# Update appearance based on whether workspace is focused
if [ "$WORKSPACE_ID" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.drawing=on
else
    sketchybar --set $NAME background.drawing=off
fi

# Show window count if there are windows
if [ "$WINDOW_COUNT" -gt 0 ]; then
    sketchybar --set $NAME label="($WINDOW_COUNT)" label.drawing=on
else
    sketchybar --set $NAME label="" label.drawing=off
fi
