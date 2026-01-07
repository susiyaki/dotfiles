#!/bin/sh

# The $NAME variable is passed from /opt/homebrew/bin/sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

/opt/homebrew/bin/sketchybar --set "$NAME" label="$(date '+%d/%m %H:%M')"

