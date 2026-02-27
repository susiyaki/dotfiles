#!/usr/bin/env bash
set -euo pipefail

model="${VOICE_INPUT_MODEL:-${XDG_DATA_HOME:-$HOME/.local/share}/whisper/ggml-small-q5_1.bin}"
# Expand literal $HOME in env-provided path (home.sessionVariables does not expand it)
model="${model//\$HOME/$HOME}"
lang="${VOICE_INPUT_LANGUAGE:-ja}"
duration="${VOICE_INPUT_DURATION:-20}"
warn_before="${VOICE_INPUT_WARN_BEFORE:-5}"

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
state_dir="${runtime_dir}/voice-input"
pidfile="${state_dir}/pw-record.pid"
wavfile="${state_dir}/voice.wav"
lockfile="${state_dir}/transcribe.lock"
statusfile="${state_dir}/voice.status"
mkdir -p "$state_dir"

if ! command -v pw-record >/dev/null 2>&1; then
  notify-send "Voice input" "pw-record が見つかりません。pipewire を確認してください。"
  exit 1
fi

if ! command -v whisper-cli >/dev/null 2>&1; then
  notify-send "Voice input" "whisper-cli が見つかりません。"
  exit 1
fi

if [[ ! -f "$model" ]]; then
  notify-send "Voice input" "モデルが見つかりません: $model"
  exit 1
fi

set_status() {
  printf '%s\n' "$1" > "$statusfile"
}

if [[ ! -f "$statusfile" ]]; then
  set_status "idle"
fi

transcribe() {
  local target_wavfile="$1"
  if [[ -z "$target_wavfile" || ! -f "$target_wavfile" ]]; then
    return 1 # Exit if no file is provided
  fi

  local base_name
  base_name="$(basename "$target_wavfile" .wav)"
  local unique_lockfile="${state_dir}/${base_name}.lock"

  # Use a lock to prevent multiple transcriptions of the *same* file
  if ! mkdir "$unique_lockfile" 2>/dev/null; then
    return 0
  fi

  # This trap ensures cleanup even if the script fails
  trap 'rm -f "$target_wavfile" "$unique_lockfile"' EXIT

  set_status "transcribing" # Update main status, though it will be quickly overwritten
  notify-send "Voice input" "文字起こしを開始しました..."

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"; rm -f "$target_wavfile" "$unique_lockfile"' EXIT

  whisper-cli -m "$model" -l "$lang" -f "$target_wavfile" -otxt -of "$tmpdir/out" >/dev/null 2>&1

  if [[ ! -f "$tmpdir/out.txt" ]]; then
    notify-send "Voice input" "文字起こしに失敗しました。"
    set_status "error" # This will be the last status if it fails
    return 1
  fi

  text="$(tr -d '\r' < "$tmpdir/out.txt" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

  if [[ -z "$text" ]]; then
    notify-send "Voice input" "認識結果が空でした。"
    set_status "error"
    return 1
  fi

  printf '%s' "$text" | wl-copy

  # Simulate a paste action (Ctrl+V) which is much more robust than typing.
  wtype -M ctrl -P v -p v -m ctrl

  notify-send "Voice input" "入力しました（クリップボードにもコピー済み）。"
  # Don't set status to idle here, because a new recording might be in progress
  return 0
}

# This function stops the recording and starts transcription in the background
stop_and_transcribe() {
  if ! kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    # Process is already gone
    rm -f "$pidfile"
    return
  fi
  kill "$(cat "$pidfile")" >/dev/null 2>&1 || true
  rm -f "$pidfile"
  sleep 0.2 # Give it a moment to finalize the file

  if [[ ! -f "$wavfile" ]]; then
    return # No file to transcribe
  fi

  # Move the recorded file to a unique name to allow a new recording to start
  unique_wavfile="${wavfile%.wav}-$(date +%s%N).wav"
  mv "$wavfile" "$unique_wavfile"

  # Transcribe in the background
  transcribe "$unique_wavfile" &
  disown "$!"
}

# Main logic
if [[ -f "$pidfile" ]]; then
  # Recording in progress: stop it and transcribe
  stop_and_transcribe
  exit 0
fi

# No recording in progress: start a new one
notify-send "Voice input" "Recording... (もう一度押すと停止)"
set_status "recording"

pw-record --channels 1 --rate 16000 --format s16 "$wavfile" 2>/dev/null &
echo $! > "$pidfile"

# Safety: stop recording automatically after duration
(
  if [[ "$duration" -gt "$warn_before" ]]; then
    sleep "$((duration - warn_before))"
    if [[ -f "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
      notify-send "Voice input" "あと${warn_before}秒で停止します"
    fi
    sleep "$warn_before"
  else
    sleep "$duration"
  fi
  
  if [[ -f "$pidfile" ]]; then
    # Use the same stop_and_transcribe logic
    stop_and_transcribe
  fi
) &
disown "$!"

exit 0
