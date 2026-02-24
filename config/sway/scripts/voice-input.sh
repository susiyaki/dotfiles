#!/usr/bin/env bash
set -euo pipefail

model="${VOICE_INPUT_MODEL:-${XDG_DATA_HOME:-$HOME/.local/share}/whisper/ggml-small-q5_1.bin}"
# Expand literal $HOME in env-provided path (home.sessionVariables does not expand it)
model="${model//\$HOME/$HOME}"
lang="${VOICE_INPUT_LANGUAGE:-ja}"
duration="${VOICE_INPUT_DURATION:-8}"

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
  if ! mkdir "$lockfile" 2>/dev/null; then
    return 0
  fi
  set_status "transcribing"
  notify-send "Voice input" "Transcribing..."
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"; rmdir "$lockfile" 2>/dev/null || true' EXIT

  whisper-cli -m "$model" -l "$lang" -f "$wavfile" -otxt -of "$tmpdir/out" >/dev/null 2>&1

  if [[ ! -f "$tmpdir/out.txt" ]]; then
    notify-send "Voice input" "文字起こしに失敗しました。"
    set_status "error"
    return 1
  fi

  text="$(tr -d '\r' < "$tmpdir/out.txt" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

  if [[ -z "$text" ]]; then
    notify-send "Voice input" "認識結果が空でした。"
    set_status "error"
    return 1
  fi

  printf '%s' "$text" | wl-copy
  wtype -- "$text"

  notify-send "Voice input" "入力しました（クリップボードにもコピー済み）。"
  set_status "idle"
  return 0
}

if [[ -f "$pidfile" ]]; then
  if kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    kill "$(cat "$pidfile")" >/dev/null 2>&1 || true
  fi
  rm -f "$pidfile"
  sleep 0.2
  transcribe
  exit 0
fi

notify-send "Voice input" "Recording... (もう一度押すと停止)"
set_status "recording"
# Record WAV (s16, 16kHz) for whisper-cli
pw-record --channels 1 --rate 16000 --format s16 "$wavfile" 2>/dev/null &
echo $! > "$pidfile"

# Safety: stop recording automatically after duration
(
  sleep "$duration"
  if [[ -f "$pidfile" ]]; then
    if kill -0 "$(cat "$pidfile")" 2>/dev/null; then
      kill "$(cat "$pidfile")" >/dev/null 2>&1 || true
    fi
    rm -f "$pidfile"
    sleep 0.2
    transcribe
  fi
) &

exit 0
