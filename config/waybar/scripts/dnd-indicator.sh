#!/bin/bash

DND_STATUS=$(swaync-client -D)

if [ "$DND_STATUS" = "true" ]; then
    echo '{"text": "⊝", "class": "dnd-on", "tooltip": "Do not disturb: ON\nClick to toggle"}'
else
    echo '{"text": "⊝", "class": "dnd-off", "tooltip": "Do not disturb: OFF\nClick to toggle"}'
fi
