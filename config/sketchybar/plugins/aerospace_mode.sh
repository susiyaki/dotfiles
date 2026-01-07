#!/bin/bash

# Set PATH for launchd environment
export PATH="/opt/homebrew/bin:$PATH"

# Display current AeroSpace mode
# $MODE is set by AeroSpace via on-mode-changed

if [ "$MODE" = "main" ]; then
    # Main mode - hide the indicator
    /opt/homebrew/bin/sketchybar --set aerospace_mode label="" label.drawing=off
else
    # Other modes (resize, service, etc.) - show the mode name
    /opt/homebrew/bin/sketchybar --set aerospace_mode label="[$MODE]" label.drawing=on
fi
