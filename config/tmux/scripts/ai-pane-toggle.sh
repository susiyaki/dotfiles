#!/usr/bin/env bash

# AI Assistant pane toggle/open
# - Keep AI history per window + assistant via marker: ai_pane_<window_id>_<assistant>
# - At most one AI pane is attached in a window at a time
# - Park detached AI panes in a shared session: ai-assistant

ACTION="${AI_ACTION:-toggle}"
AI_SESSION="ai-assistant"

CURRENT_PANE=$(tmux display -p '#{pane_id}')
CURRENT_WINDOW_ID=$(tmux display -p '#{window_id}')
CURRENT_NVIM_ID=$(tmux display -p '#{@nvim_instance_id}')
CURRENT_COMMAND=$(tmux display -p '#{pane_current_command}')
CURRENT_AI_MARKER=$(tmux display -p '#{@ai_pane_marker}')
CURRENT_WINDOW_ASSISTANT=$(tmux show-options -wqv -t "$CURRENT_WINDOW_ID" @ai_assistant 2>/dev/null)

ASSISTANT="${AI_ASSISTANT:-$CURRENT_WINDOW_ASSISTANT}"
if [ -z "$ASSISTANT" ]; then
  ASSISTANT="$(tmux show-environment -g AI_ASSISTANT 2>/dev/null | cut -d= -f2)"
fi
[ -z "$ASSISTANT" ] && ASSISTANT="claude"

if [ -n "$CURRENT_AI_MARKER" ]; then
  CURRENT_PANE_ASSISTANT=$(tmux display -p '#{@ai_assistant}')
  [ -n "$CURRENT_PANE_ASSISTANT" ] && ASSISTANT="$CURRENT_PANE_ASSISTANT"
fi

TARGET_MARKER="ai_pane_${CURRENT_WINDOW_ID}_${ASSISTANT}"
WINDOW_MARKER_PREFIX="ai_pane_${CURRENT_WINDOW_ID}_"

ensure_ai_session() {
  if ! tmux has-session -t "$AI_SESSION" 2>/dev/null; then
    tmux new-session -d -s "$AI_SESSION"
  fi
}

move_pane_to_ai_session() {
  local pane_id="$1"
  [ -z "$pane_id" ] && return 0

  ensure_ai_session
  tmux break-pane -d -s "$pane_id"

  local temp_window
  temp_window=$(tmux display -p -t "$pane_id" '#{window_id}')
  if [ -n "$temp_window" ]; then
    tmux move-window -s "$temp_window" -t "$AI_SESSION:"
  fi
}

build_ai_cmd() {
  local args="${AI_ARGS:-}"
  case "$ASSISTANT" in
    claude) echo "claude $args" ;;
    gemini) echo "gemini $args" ;;
    codex)  echo "codex $args" ;;
    *)      echo "echo 'AI_ASSISTANT not set'; sleep 5" ;;
  esac
}

create_new_ai_pane() {
  local working_dir="${NVIM_CWD:-$(tmux display -p '#{pane_current_path}')}"
  local cmd
  cmd=$(build_ai_cmd)

  local new_pane
  new_pane=$(tmux split-window -h -p 50 -c "$working_dir" \
    -e NVIM_INSTANCE_ID="$CURRENT_NVIM_ID" \
    -e AI_ASSISTANT="$ASSISTANT" \
    -e AI_ARGS="${AI_ARGS:-}" \
    -P -F "#{pane_id}" \
    "$cmd")

  if [ -n "$new_pane" ]; then
    tmux set-option -p -t "$new_pane" @ai_pane_marker "$TARGET_MARKER"
    tmux set-option -p -t "$new_pane" @ai_assistant "$ASSISTANT"
    tmux select-pane -t "$new_pane" -T "ai-${ASSISTANT}-${CURRENT_WINDOW_ID}"
    tmux select-pane -L
  fi
}

find_target_pane_anywhere() {
  tmux list-panes -a -F "#{session_name} #{window_index} #{pane_id} #{@ai_pane_marker}" 2>/dev/null \
    | grep " ${TARGET_MARKER}$" \
    | head -n 1
}

find_any_ai_pane_in_current_window() {
  tmux list-panes -F "#{pane_id} #{@ai_pane_marker}" 2>/dev/null \
    | grep " ${WINDOW_MARKER_PREFIX}" \
    | awk '{print $1}' \
    | head -n 1
}

is_nvim_context=false
if [ -n "$CURRENT_NVIM_ID" ] || [ "$CURRENT_COMMAND" = "nvim" ] || [ "$CURRENT_COMMAND" = "vim" ]; then
  is_nvim_context=true
fi

if [ "$is_nvim_context" = true ]; then
  tmux set-option -wq -t "$CURRENT_WINDOW_ID" @ai_assistant "$ASSISTANT"

  TARGET_IN_WINDOW=$(tmux list-panes -F "#{pane_id} #{@ai_pane_marker}" 2>/dev/null | grep " ${TARGET_MARKER}$" | awk '{print $1}' | head -n 1)

  if [ -n "$TARGET_IN_WINDOW" ]; then
    if [ "$ACTION" = "open" ]; then
      exit 0
    fi
    move_pane_to_ai_session "$TARGET_IN_WINDOW"
    exit 0
  fi

  # Different assistant pane is currently attached -> park it first.
  ATTACHED_OTHER=$(find_any_ai_pane_in_current_window)
  if [ -n "$ATTACHED_OTHER" ]; then
    move_pane_to_ai_session "$ATTACHED_OTHER"
  fi

  TARGET_INFO=$(find_target_pane_anywhere)
  if [ -n "$TARGET_INFO" ]; then
    TARGET_SESS=$(echo "$TARGET_INFO" | awk '{print $1}')
    TARGET_WIN=$(echo "$TARGET_INFO" | awk '{print $2}')
    TARGET_PANE=$(echo "$TARGET_INFO" | awk '{print $3}')

    if tmux list-panes -a -F "#{pane_id}" | grep -q "^${TARGET_PANE}$"; then
      tmux join-pane -h -s "${TARGET_SESS}:${TARGET_WIN}.${TARGET_PANE}" -t "$CURRENT_PANE"
      tmux set-option -p -t "$TARGET_PANE" @ai_assistant "$ASSISTANT"
      tmux select-pane -t "$TARGET_PANE" -T "ai-${ASSISTANT}-${CURRENT_WINDOW_ID}"
      exit 0
    fi
  fi

  if [ "$ACTION" = "open" ]; then
    create_new_ai_pane
  else
    tmux display-message "Error: AI pane not found in session '$AI_SESSION'. Use ,, in Neovim to create one." -d 3000
  fi
  exit 0
fi

if [ -n "$CURRENT_AI_MARKER" ]; then
  move_pane_to_ai_session "$CURRENT_PANE"
  exit 0
fi

tmux display-message "Error: Please run from Neovim pane (with @nvim_instance_id) or AI pane" -d 3000
