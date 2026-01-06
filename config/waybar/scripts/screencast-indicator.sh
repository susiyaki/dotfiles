#!/bin/bash

if pgrep -x wf-recorder > /dev/null; then
    echo '{"text": "⏺", "class": "recording", "tooltip": "Click to stop recording"}'
else
    echo '{"text": "", "class": "idle"}'
fi
