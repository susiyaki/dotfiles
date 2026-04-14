#!/usr/bin/env bash

# Kill sessions whose names are purely numeric (e.g. "0", "1", "42")
tmux list-sessions -F '#{session_name}' 2>/dev/null \
  | grep -xE '[0-9]+' \
  | while read -r s; do
      tmux kill-session -t "=$s" 2>/dev/null || true
    done

# Derive save.sh path from resurrect's restore binding
restore_path="$(tmux list-keys -T prefix C-r 2>/dev/null | grep -oP '/nix/store/\S+/restore\.sh')"
save_script="${restore_path%restore.sh}save.sh"

if [ -n "$save_script" ] && [ -x "$save_script" ]; then
  "$save_script"
else
  tmux display-message "Cleaned numeric sessions, but resurrect save script not found"
fi
