#!/usr/bin/env bash

WINDOW_ID="${1:-}"
[ -z "$WINDOW_ID" ] && exit 0

MARKER_PREFIX="ai_pane_${WINDOW_ID}_"

tmux list-panes -a -F "#{pane_id} #{@ai_pane_marker} #{pane_title}" 2>/dev/null \
  | grep " ${MARKER_PREFIX}" \
  | while read -r pane_id _ pane_title; do
      [ -z "$pane_id" ] && continue
      prompt="Close AI pane ${pane_id} (${pane_title})?"
      tmux confirm-before -p "$prompt" "kill-pane -t ${pane_id}" 2>/dev/null || true
    done

# If user keeps a pane (No in confirm dialog), keep assistant metadata as-is.
# Window option cleanup can be done later when no AI panes remain.
