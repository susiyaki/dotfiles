#!/usr/bin/env bash

WINDOW_ID="${1:-}"
[ -z "$WINDOW_ID" ] && exit 0

# Show AI segment only when the current window has an active Neovim pane
# or a pane marked as nvim instance.
HAS_NVIM_CMD=$(tmux list-panes -t "$WINDOW_ID" -F "#{pane_current_command}" 2>/dev/null | grep -E '^(nvim|vim)$' | head -n 1)
HAS_NVIM_MARKER=$(tmux list-panes -t "$WINDOW_ID" -F "#{@nvim_instance_id}" 2>/dev/null | awk 'NF { print; exit }')
if [ -z "$HAS_NVIM_CMD" ] && [ -z "$HAS_NVIM_MARKER" ]; then
  # Close the session segment even when AI segment is hidden.
  printf '#[fg=#3a3a3a,bg=#262626,nobold]'
  exit 0
fi

ASSISTANT=$(tmux display-message -p -t "$WINDOW_ID" '#{@ai_assistant}' 2>/dev/null)
if [ -z "$ASSISTANT" ]; then
  ASSISTANT="$(tmux show-environment -g AI_ASSISTANT 2>/dev/null | cut -d= -f2)"
fi
[ -z "$ASSISTANT" ] && ASSISTANT="claude"

printf '#[fg=#3a3a3a,bg=#93a3a2,nobold]#[fg=#262626,bg=#93a3a2,nobold] 󰚩 %s #[fg=#93a3a2,bg=#262626,nobold]' "$ASSISTANT"
