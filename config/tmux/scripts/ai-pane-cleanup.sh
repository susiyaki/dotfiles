#!/usr/bin/env bash

WINDOW_ID="${1:-}"
[ -z "$WINDOW_ID" ] && exit 0

MARKER_PREFIX="ai_pane_${WINDOW_ID}_"

tmux list-panes -a -F "#{pane_id} #{@ai_pane_marker}" 2>/dev/null \
  | grep " ${MARKER_PREFIX}" \
  | awk '{print $1}' \
  | while read -r pane_id; do
      [ -n "$pane_id" ] && tmux kill-pane -t "$pane_id" 2>/dev/null || true
    done

tmux set-option -wqu -t "$WINDOW_ID" @ai_assistant 2>/dev/null || true
