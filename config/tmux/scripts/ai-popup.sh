#!/bin/bash

# AI Assistant popup スクリプト

# エラーログファイル
ERROR_LOG="/tmp/ai-popup-error.log"

# AI_ASSISTANT が設定されているかチェック
if [ -z "$AI_ASSISTANT" ]; then
  echo "Error: AI_ASSISTANT environment variable is not set" >> "$ERROR_LOG"
  tmux display-message "Error: AI_ASSISTANT not set. Check /tmp/ai-popup-error.log"
  exit 1
fi

ASSISTANT="$AI_ASSISTANT"
INSTANCE_ID="${NVIM_INSTANCE_ID:-$(tmux display -p '#{pane_id}')}"
SESSION_NAME="ai-${ASSISTANT}-${INSTANCE_ID}"

# カレントディレクトリの決定
# NVIM_CWD（Neovim から渡される）があればそれを使用、なければ tmux の pane_current_path
if [ -n "$NVIM_CWD" ]; then
  WORKING_DIR="$NVIM_CWD"
else
  WORKING_DIR="$(tmux display -p '#{pane_current_path}')"
fi

# AI Assistant に応じたコマンドを設定
case "$ASSISTANT" in
  claude)
    CMD="claude code"
    ;;
  gemini)
    CMD="gemini-cli"
    ;;
  *)
    echo "Error: Unknown AI_ASSISTANT: $ASSISTANT" >> "$ERROR_LOG"
    tmux display-message "Error: Unknown AI_ASSISTANT: $ASSISTANT"
    exit 1
    ;;
esac

# popup を表示（環境変数とカレントディレクトリを明示的に tmux に渡す）
tmux display-popup -E -w 90% -h 90% -d "$WORKING_DIR" \
  "tmux attach -t ${SESSION_NAME} 2>/dev/null || \
   tmux new -s ${SESSION_NAME} -c \"${WORKING_DIR}\" -e NVIM_INSTANCE_ID=${INSTANCE_ID} -e AI_ASSISTANT=${ASSISTANT} '${CMD}'"
