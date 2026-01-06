#!/bin/bash

# Display all apps in the focused workspace
# Focused window: full name in bright color
# Unfocused windows: first letter in dim color

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
FOCUSED_WINDOW=$(aerospace list-windows --focused 2>/dev/null | head -n 1 | awk '{print $1}')

# Get all windows in the focused workspace
WINDOWS=$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" 2>/dev/null)

if [ -z "$WINDOWS" ]; then
    sketchybar --set aerospace_apps_focused label="" label.drawing=off
    sketchybar --set aerospace_apps_unfocused label="" label.drawing=off
else
    FOCUSED_APP=""
    UNFOCUSED_APPS=""

    while IFS= read -r line; do
        WINDOW_ID=$(echo "$line" | awk '{print $1}')
        APP_NAME=$(echo "$line" | awk '{print $3}')

        if [ "$WINDOW_ID" = "$FOCUSED_WINDOW" ]; then
            # Focused window: full name
            FOCUSED_APP="$APP_NAME"
        else
            # Unfocused windows: first letter
            FIRST_LETTER=$(echo "$APP_NAME" | cut -c1)
            UNFOCUSED_APPS+="$FIRST_LETTER "
        fi
    done <<< "$WINDOWS"

    # Update focused app (bright color)
    if [ -n "$FOCUSED_APP" ]; then
        sketchybar --set aerospace_apps_focused label="$FOCUSED_APP" label.drawing=on
    else
        sketchybar --set aerospace_apps_focused label="" label.drawing=off
    fi

    # Update unfocused apps (dim color)
    if [ -n "$UNFOCUSED_APPS" ]; then
        sketchybar --set aerospace_apps_unfocused label="$UNFOCUSED_APPS" label.drawing=on
    else
        sketchybar --set aerospace_apps_unfocused label="" label.drawing=off
    fi
fi
