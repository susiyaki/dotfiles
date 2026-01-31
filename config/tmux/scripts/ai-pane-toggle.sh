#!/bin/bash

# AI Assistant をペインで開く/退避させるスクリプト
# - AI paneの名前にneovim IDを含める
# - フォーカスによって動作を変える（neovimペイン → 持ってくる、AI pane → 送る）

ASSISTANT="${AI_ASSISTANT:-$(tmux show-environment -g AI_ASSISTANT 2>/dev/null | cut -d= -f2)}"
ACTION="${AI_ACTION:-toggle}"

# 現在のペイン情報を取得
CURRENT_PANE=$(tmux display -p '#{pane_id}')
CURRENT_SESSION=$(tmux display -p '#{session_name}')
CURRENT_NVIM_ID=$(tmux display -p '#{@nvim_instance_id}')
CURRENT_AI_MARKER=$(tmux display -p '#{@ai_pane_marker}')

# AI専用セッション名の形式: ai-claude, ai-gemini
AI_SESSION="ai-${ASSISTANT}"

# 現在のペインがneovimペインの場合
if [ -n "$CURRENT_NVIM_ID" ]; then

  # AI paneのマーカー
  AI_PANE_MARKER="ai_pane_${CURRENT_NVIM_ID}"

  # まず現在のウィンドウにAI paneがあるかチェック
  CURRENT_WINDOW_AI_PANE=$(tmux list-panes -F "#{pane_id} #{@ai_pane_marker}" | grep "$AI_PANE_MARKER" | awk '{print $1}')

  if [ -n "$CURRENT_WINDOW_AI_PANE" ]; then
    if [ "$ACTION" = "open" ]; then
      # openモードの場合、既にAIペインがあれば何もしない
      exit 0
    fi

    # toggleモードの場合、既に現在のウィンドウにある → AI専用セッションに送る

    # AI専用セッションが存在しない場合は作成
    if ! tmux has-session -t "$AI_SESSION" 2>/dev/null; then
      tmux new-session -d -s "$AI_SESSION"
    fi

    # ペインをウィンドウとして独立させる
    tmux break-pane -d -s "$CURRENT_WINDOW_AI_PANE"

    # break-pane後、そのペインのウィンドウIDを取得
    TEMP_WINDOW=$(tmux display -p -t "$CURRENT_WINDOW_AI_PANE" '#{window_id}')
    if [ -n "$TEMP_WINDOW" ]; then
      tmux move-window -s "$TEMP_WINDOW" -t "$AI_SESSION:"
    fi
    exit 0
  fi

  # AI専用セッションから対応するペインを探す
  if tmux has-session -t "$AI_SESSION" 2>/dev/null; then
    AI_PANE_INFO=$(tmux list-panes -a -t "$AI_SESSION" -F "#{session_name} #{window_index} #{pane_id} #{@ai_pane_marker}" 2>/dev/null | grep "$AI_PANE_MARKER")
  else
    AI_PANE_INFO=""
  fi

  if [ -n "$AI_PANE_INFO" ]; then
    # AI専用セッションに見つかった → 持ってくる
    AI_PANE_WINDOW=$(echo "$AI_PANE_INFO" | awk '{print $2}')
    AI_PANE=$(echo "$AI_PANE_INFO" | awk '{print $3}')

    # ペインが実際に存在するか確認
    if tmux list-panes -a -F "#{pane_id}" | grep -q "^${AI_PANE}$"; then
      tmux join-pane -h -s "${AI_SESSION}:${AI_PANE_WINDOW}.${AI_PANE}" -t "$CURRENT_PANE"
    else
      tmux display-message "Error: AI pane $AI_PANE not found" -d 3000
    fi
  else
    # 見つからない
    if [ "$ACTION" = "open" ]; then
      # 新規作成
      WORKING_DIR="${NVIM_CWD:-$(tmux display -p '#{pane_current_path}')}"

      # AI コマンドを決定
      case "$ASSISTANT" in
        claude) CMD="claude code" ;;
        gemini) CMD="gemini-cli" ;;
        *) CMD="echo 'AI_ASSISTANT not set'; sleep 5" ;;
      esac

      NEW_PANE=$(tmux split-window -h -p 50 -c "$WORKING_DIR" \
        -e NVIM_INSTANCE_ID="$CURRENT_NVIM_ID" \
        -e AI_ASSISTANT="$ASSISTANT" \
        -P -F "#{pane_id}" \
        "$CMD")

      EXIT_CODE=$?

      if [ $EXIT_CODE -eq 0 ] && [ -n "$NEW_PANE" ]; then
        # 新しく作成された pane にマーカーとタイトルを設定
        tmux set-option -p -t "$NEW_PANE" @ai_pane_marker "$AI_PANE_MARKER"
        tmux select-pane -t "$NEW_PANE" -T "ai-${ASSISTANT}-nvim${CURRENT_NVIM_ID}"

        # 元の pane にフォーカスを戻す
        tmux select-pane -L
      fi
    else
      # toggleモードでは新規作成しない
      tmux display-message "Error: AI pane not found in session '$AI_SESSION'. Use ,, in Neovim to create one." -d 3000
    fi
  fi

# 現在のペインがAI paneの場合
elif [ -n "$CURRENT_AI_MARKER" ]; then

  # AI専用セッションに送る
  # AI専用セッションが存在しない場合は作成
  if ! tmux has-session -t "$AI_SESSION" 2>/dev/null; then
    tmux new-session -d -s "$AI_SESSION"
  fi

  # ペインをウィンドウとして独立させる
  tmux break-pane -d -s "$CURRENT_PANE"

  # break-pane後、そのペインのウィンドウIDを取得
  TEMP_WINDOW=$(tmux display -p -t "$CURRENT_PANE" '#{window_id}')
  if [ -n "$TEMP_WINDOW" ]; then
    tmux move-window -s "$TEMP_WINDOW" -t "$AI_SESSION:"
  fi

# どちらでもない場合
else
  tmux display-message "Error: Please run from Neovim pane (with @nvim_instance_id) or AI pane" -d 3000
fi
