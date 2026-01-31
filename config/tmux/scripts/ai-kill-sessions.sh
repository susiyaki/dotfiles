#!/bin/bash

# AI Assistant セッションをまとめて削除するスクリプト

# AI セッションの一覧を取得
AI_SESSIONS=$(tmux list-sessions 2>/dev/null | grep '^ai-' | cut -d: -f1)

if [ -z "$AI_SESSIONS" ]; then
  tmux display-message "No AI sessions found"
  exit 0
fi

# セッション数をカウント
SESSION_COUNT=$(echo "$AI_SESSIONS" | wc -l)

# 確認メッセージを表示
tmux display-popup -E -w 60% -h 30% -d "#{pane_current_path}" "bash -c '
  echo \"Found $SESSION_COUNT AI session(s):\"
  echo \"\"
  echo \"$AI_SESSIONS\" | sed \"s/^/  - /\"
  echo \"\"
  echo -n \"Kill all AI sessions? [y/N]: \"
  read -r REPLY
  if [[ \$REPLY =~ ^[Yy]$ ]]; then
    echo \"\"
    echo \"Killing sessions...\"
    echo \"$AI_SESSIONS\" | while read -r session; do
      tmux kill-session -t \"\$session\" 2>/dev/null
      echo \"  Killed: \$session\"
    done
    echo \"\"
    echo \"Done. Press any key to close.\"
    read -n 1
  else
    echo \"Cancelled.\"
    sleep 1
  fi
'"
