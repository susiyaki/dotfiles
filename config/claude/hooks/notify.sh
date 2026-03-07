#!/usr/bin/env bash
set -euo pipefail

# Usage: notify.sh <event_type>
#   Reads Claude Code hook JSON from stdin.
#   event_type: "permission" or "idle"

EVENT_TYPE="${1:-unknown}"

if [[ -f "$HOME/.claude/ha.env" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.claude/ha.env"
fi

: "${NAS_TAILSCALE_IP:=100.96.43.9}"
: "${HA_WEBHOOK_URL:=http://${NAS_TAILSCALE_IP}:8123/api/webhook/claude_code_hook}"
: "${CLAUDE_CONFIRM_RESULT_FILE:=/mnt/nas-docker/projects/homeassistant/config/claude_confirm_result.json}"
CLAUDE_CONFIRM_TIMEOUT_SEC="${CLAUDE_CONFIRM_TIMEOUT_SEC:-300}"
CLAUDE_CONFIRM_POLL_INTERVAL_SEC="${CLAUDE_CONFIRM_POLL_INTERVAL_SEC:-5}"

# --- Read stdin JSON ---
stdin_json="$(cat)"

json_field() {
  echo "$stdin_json" | jq -r "$1 // empty" 2>/dev/null || true
}

# Waits for a Home Assistant confirmation result file update.
# Prints one of: ok / ng / timeout
wait_for_ha_confirmation() {
  local since_ts="${1:-0}"
  local deadline
  local now
  local result
  local result_ts
  local file_mtime

  if ! command -v jq >/dev/null 2>&1; then
    echo "timeout"
    return 0
  fi

  now="$(date +%s)"
  deadline=$((now + CLAUDE_CONFIRM_TIMEOUT_SEC))

  while :; do
    now="$(date +%s)"
    if (( now >= deadline )); then
      echo "timeout"
      return 0
    fi

    if [[ -f "$CLAUDE_CONFIRM_RESULT_FILE" ]]; then
      result="$(jq -r '.result // empty' "$CLAUDE_CONFIRM_RESULT_FILE" 2>/dev/null || true)"
      result_ts="$(jq -r '.timestamp // empty' "$CLAUDE_CONFIRM_RESULT_FILE" 2>/dev/null || true)"

      if [[ -z "$result_ts" ]] || ! [[ "$result_ts" =~ ^[0-9]+$ ]]; then
        file_mtime="$(stat -c %Y "$CLAUDE_CONFIRM_RESULT_FILE" 2>/dev/null || stat -f %m "$CLAUDE_CONFIRM_RESULT_FILE" 2>/dev/null || echo 0)"
        result_ts="$file_mtime"
      fi

      if [[ "$result" == "ok" || "$result" == "ng" ]]; then
        if [[ "$result_ts" =~ ^[0-9]+$ ]] && (( result_ts >= since_ts )); then
          echo "$result"
          return 0
        fi
      fi
    fi

    sleep "$CLAUDE_CONFIRM_POLL_INTERVAL_SEC"
  done
}

session_id="$(json_field '.session_id')"
cwd="$(json_field '.cwd')"
project="${cwd##*/}"
tool_name="$(json_field '.tool_name')"
tool_input_command="$(json_field '.tool_input.command')"
tool_input_file="$(json_field '.tool_input.file_path')"
tool_input_pattern="$(json_field '.tool_input.pattern')"
tool_input_desc="$(json_field '.tool_input.description')"

# --- Tmux context ---
tmux_session="$(tmux display-message -p '#{session_name}' 2>/dev/null || echo '')"
tmux_pane="$(tmux display-message -p '#{window_index}.#{pane_index}' 2>/dev/null || echo '')"

# --- Build tool detail line ---
tool_detail=""
if [[ -n "$tool_name" ]]; then
  case "$tool_name" in
    Bash)
      cmd="${tool_input_command}"
      if [[ ${#cmd} -gt 60 ]]; then
        cmd="${cmd:0:57}..."
      fi
      tool_detail="$tool_name: $cmd"
      ;;
    Write|Read|Edit)
      tool_detail="$tool_name: ${tool_input_file:-?}"
      ;;
    Glob)
      tool_detail="$tool_name: ${tool_input_pattern:-?}"
      ;;
    Grep)
      pat="$(json_field '.tool_input.pattern')"
      tool_detail="$tool_name: ${pat:-?}"
      ;;
    Agent)
      desc="$(json_field '.tool_input.description')"
      tool_detail="$tool_name: ${desc:-?}"
      ;;
    *)
      tool_detail="$tool_name"
      ;;
  esac
fi

# --- Notification content ---
case "$EVENT_TYPE" in
  permission)
    title="🔐 Permission Required"
    ;;
  idle)
    title="💬 Input Required"
    ;;
  *)
    title="🔔 Notification"
    ;;
esac

# Section: header
header="[$project]"
[[ -n "$tmux_session" ]] && header+=" tmux:$tmux_session"
[[ -n "$tmux_pane" ]] && header+=".$tmux_pane"

# Short session id suffix for identification
sid_short="${session_id:0:8}"
session_label="${sid_short:-no-session}"
tmux_label="${tmux_session:-no-tmux}${tmux_pane:+.$tmux_pane}"
tmux_session_label="${tmux_session:-no-tmux}"

# Section: body (multiline)
body="$header"
body+=$'\n'"session:$session_label"
[[ -n "$tool_detail" ]] && body+=$'\n'"→ $tool_detail"
[[ -n "$tool_input_desc" && "$tool_name" == "Bash" ]] && body+=$'\n'"  $tool_input_desc"

ha_message="$title [$project]"
ha_message+=$'\n'"[$session_label]: $tmux_session_label"
[[ -n "$tool_detail" ]] && ha_message+=$'\n'"$tool_detail"

# --- Desktop notification ---
if command -v notify-send >/dev/null 2>&1; then
  notify-send \
    -a "Claude Code" \
    -u normal \
    "$title" \
    "$body"
elif command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier \
    -title "$title" \
    -subtitle "$header" \
    -message "${tool_detail:-Ready}" \
    -sender com.apple.Terminal \
    -ignoreDnD
fi

# --- Home Assistant webhook ---
wait_started_at="$(date +%s)"

ha_payload="$(jq -n \
  --arg title "$title" \
  --arg message "$ha_message" \
  --arg project "$project" \
  --arg cwd "${cwd:-}" \
  --arg tmux "$tmux_label" \
  --arg tmux_session "${tmux_session:-}" \
  --arg tmux_pane "${tmux_pane:-}" \
  --arg tool "${tool_detail:-}" \
  --arg desc "${tool_input_desc:-}" \
  --arg sid "$session_label" \
  --arg event "$EVENT_TYPE" \
  '{
    message: $message,
    data: {
      event: $event,
      project: $project,
      cwd: $cwd,
      tmux: $tmux,
      tmux_session: $tmux_session,
      tmux_pane: $tmux_pane,
      tool: $tool,
      description: $desc,
      session_id: $sid
    }
  }'
)"

curl -s -o /dev/null -m 5 \
  -H "Content-Type: application/json" \
  -d "$ha_payload" \
  "$HA_WEBHOOK_URL" 2>/dev/null || true

if [[ "$EVENT_TYPE" != "permission" ]]; then
  exit 0
fi

result="$(wait_for_ha_confirmation "$wait_started_at")"

case "$result" in
  ok)
    # Exit 0 when the user approved via Home Assistant.
    echo "[notify.sh] User approved via HA (result=ok)" >&2
    exit 0
    ;;
  ng)
    # Exit 1 when the user explicitly rejected via Home Assistant.
    echo "[notify.sh] User rejected via HA (result=ng)" >&2
    exit 1
    ;;
  timeout|*)
    # Exit 2 when no valid response was received before timeout.
    echo "[notify.sh] No response from HA (timeout)" >&2
    exit 2
    ;;
esac

# Example:
#   permission + HA result=ok      -> exit 0
#   permission + HA result=ng      -> exit 1
#   permission + no response       -> exit 2
#   idle / other event types       -> exit 0
