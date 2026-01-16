#!/bin/bash

# Check systemd status
SYSTEMD_STATUS=$(systemctl --user is-active speak-to-ai 2>/dev/null)

if [ "$SYSTEMD_STATUS" != "active" ]; then
    echo '{"text": "", "class": "inactive", "tooltip": "Daemon not running (Click to restart)"}'
    exit 0
fi

# Check recording status
RECORDING_STATUS=$(speak-to-ai status 2>/dev/null)
if echo "$RECORDING_STATUS" | grep -qi "Recording: true"; then
    echo '{"text": "", "class": "recording", "tooltip": "Recording in progress (Click to stop)"}'
else
    echo '{"text": "", "class": "idle", "tooltip": "Ready (Click to start recording)"}'
fi
