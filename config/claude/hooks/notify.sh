#!/usr/bin/env bash
set -euo pipefail

# Usage: notify.sh <event_type>
#   Reads Claude Code hook JSON from stdin.
#   event_type: "permission" or "idle"

EVENT_TYPE="${1:-unknown}"
HA_WEBHOOK_URL="http://100.96.43.9:8123/api/webhook/claude_code_hook"

# --- Read stdin JSON ---
stdin_json="$(cat)"

json_field() {
  echo "$stdin_json" | jq -r "$1 // empty" 2>/dev/null || true
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

# Section: body (multiline)
body="$header"
[[ -n "$tool_detail" ]] && body+=$'\n'"→ $tool_detail"
[[ -n "$tool_input_desc" && "$tool_name" == "Bash" ]] && body+=$'\n'"  $tool_input_desc"

# Short session id suffix for identification
sid_short="${session_id:0:8}"
[[ -n "$sid_short" ]] && body+=$'\n'"sid:$sid_short"

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
ha_payload="$(jq -n \
  --arg title "$title" \
  --arg project "$project" \
  --arg tmux "${tmux_session}${tmux_pane:+.$tmux_pane}" \
  --arg tool "${tool_detail:-}" \
  --arg desc "${tool_input_desc:-}" \
  --arg sid "${sid_short:-}" \
  --arg event "$EVENT_TYPE" \
  '{
    message: "\($title) — \($project)",
    data: {
      event: $event,
      project: $project,
      tmux: $tmux,
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
