#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
event=""

if command -v jq >/dev/null 2>&1; then
  event="$(printf '%s' "$payload" | jq -r '.event // .type // .name // empty')"
fi

session="$(tmux display-message -p '#{session_name}' 2>/dev/null || echo 'unknown')"
tmux_info="$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null || echo 'unknown')"

title="Codex ($session)"
body="Notification"

case "$event" in
  approval-requested)
    body="Permission Required"
    ;;
  agent-turn-complete)
    body="Input Required"
    ;;
esac

if command -v notify-send >/dev/null 2>&1; then
  notify-send -a "$title" "$body" "From: $tmux_info"
fi
