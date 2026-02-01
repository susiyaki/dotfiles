#!/usr/bin/env bash

# Get the focused window's app_id (Wayland) or class (XWayland)
focused_window=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true)')
app_id=$(echo "$focused_window" | jq -r '.app_id // .window_properties.class // empty')

# 1Password is excluded from clipboard history
if [[ "$app_id" != "1Password" ]]; then
    # --no-persist so that we preserve rich text:
    clipman store --no-persist
fi