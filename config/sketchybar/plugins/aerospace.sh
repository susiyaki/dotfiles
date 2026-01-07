#!/bin/bash

# Set PATH for launchd environment
export PATH="/opt/homebrew/bin:$PATH"

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

# Find the focused monitor (the monitor containing the focused workspace)
FOCUSED_MONITOR=""
for monitor in $(aerospace list-monitors | awk '{print $1}'); do
    workspace=$(aerospace list-workspaces --monitor "$monitor" 2>/dev/null)
    if [ "$workspace" = "$FOCUSED_WORKSPACE" ]; then
        FOCUSED_MONITOR="$monitor"
        break
    fi
done

# Get all visible workspaces (one per monitor)
VISIBLE_WORKSPACES=""
for monitor in $(aerospace list-monitors | awk '{print $1}'); do
    workspace=$(aerospace list-workspaces --monitor "$monitor" 2>/dev/null)
    if [ -n "$workspace" ]; then
        VISIBLE_WORKSPACES="$VISIBLE_WORKSPACES"$'\n'"$workspace"
    fi
done

# Get the workspace displayed on the focused monitor
FOCUSED_MONITOR_WORKSPACE=$(aerospace list-workspaces --monitor "$FOCUSED_MONITOR" 2>/dev/null)

# Update appearance based on workspace state (Sway-like behavior)
if [ "$WORKSPACE_ID" = "$FOCUSED_WORKSPACE" ]; then
    # Focused workspace: darker gray
    /opt/homebrew/bin/sketchybar --set $NAME \
        background.drawing=on \
        background.color=0xcc808080
elif echo "$VISIBLE_WORKSPACES" | grep -q "^$WORKSPACE_ID$"; then
    # Visible on another monitor (not focused): medium gray
    /opt/homebrew/bin/sketchybar --set $NAME \
        background.drawing=on \
        background.color=0x99606060
else
    # Not visible: no background
    /opt/homebrew/bin/sketchybar --set $NAME background.drawing=off
fi

# Show window count if there are windows
if [ "$WINDOW_COUNT" -gt 0 ]; then
    /opt/homebrew/bin/sketchybar --set $NAME label="($WINDOW_COUNT)" label.drawing=on
else
    /opt/homebrew/bin/sketchybar --set $NAME label="" label.drawing=off
fi
