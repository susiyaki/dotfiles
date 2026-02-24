#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/voice-input"
status_file="$state_dir/voice.status"

state="idle"
if [[ -f "$status_file" ]]; then
  state="$(tr -d '\r\n' < "$status_file")"
fi

case "$state" in
  recording)
    text="󰍬"
    class="recording"
    ;;
  transcribing)
    text="󰏪"
    class="transcribing"
    ;;
  error)
    text="󰀩"
    class="error"
    ;;
  *)
    text="󰍯"
    class="idle"
    ;;
esac

printf '{"text":"%s","class":"%s"}\n' "$text" "$class"
