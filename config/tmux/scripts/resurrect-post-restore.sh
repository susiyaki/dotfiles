#!/usr/bin/env bash
# tmux-resurrect post-restore hook
# Cleans up sessions/windows that are useless after restore

sleep 1 # wait for restore to settle

SAVE_FILE="$(readlink -f "${HOME}/.local/share/tmux/resurrect/last")"

# 1. Kill the "ai-assistant" session (empty shell after restore)
tmux kill-session -t ai-assistant 2>/dev/null

# 2. Kill sessions with numeric-only names
tmux list-sessions -F '#{session_name}' | while read -r session; do
  [[ "$session" =~ ^[0-9]+$ ]] && tmux kill-session -t "=$session" 2>/dev/null
done

# 3. Kill windows that originally had nvim (they can't be meaningfully restored)
[ -f "$SAVE_FILE" ] || exit 0

# Extract unique session:window pairs that had nvim
grep -P '^pane\t.*nvim' "$SAVE_FILE" | cut -f2,3 | sort -u | while IFS=$'\t' read -r session window_idx; do
  target="${session}:${window_idx}"

  # Skip if session is gone
  tmux has-session -t "=$session" 2>/dev/null || continue

  # Don't kill the last window in a session
  session_windows=$(tmux list-windows -t "=$session" -F '#{window_index}' | wc -l)
  [ "$session_windows" -le 1 ] && continue

  tmux kill-window -t "$target"
done
