#!/usr/bin/env bash
# Speak to AI - Voice input for Sway
# Captures voice input and types it into the current window

set -euo pipefail

# Configuration
CONFIG_FILE="$HOME/.config/speak-to-ai/config.yaml"
SOCKET_PATH="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/speak-to-ai.sock"
DND_STATE_FILE="/tmp/voice-input-dnd-state.lock"

# Notification helper
notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -t 2000 "音声入力" "$1"
    fi
}

# Check if daemon is running
is_daemon_running() {
    [ -S "$SOCKET_PATH" ] && speak-to-ai status &>/dev/null
}

# Start daemon if not running
ensure_daemon() {
    if ! is_daemon_running; then
        speak-to-ai -config "$CONFIG_FILE" &

        # Wait for daemon to be ready
        for i in {1..20}; do
            if is_daemon_running; then
                sleep 0.2  # Extra time for full initialization
                return 0
            fi
            sleep 0.2
        done

        notify "エラー: デーモンの起動に失敗しました"
        return 1
    fi
}

# Check if currently recording
is_recording() {
    local status
    status=$(speak-to-ai status 2>/dev/null || echo "Recording: false")
    echo "$status" | grep -qi "Recording: true"
}

# Main logic
main() {
    # Ensure daemon is running
    if ! ensure_daemon; then
        exit 1
    fi

    # Check current recording status
    if is_recording; then
        # Currently recording - stop and get transcript
        set +e  # Temporarily disable exit on error
        speak-to-ai stop 2>&1
        STOP_EXIT=$?
        set -e

        # Check if stop was successful
        if [ $STOP_EXIT -ne 0 ]; then
            notify "エラー: 録音の停止に失敗しました"
            exit 1
        fi

        # Wait a bit for transcript to be available
        sleep 0.2

        # Get transcript and copy to clipboard
        TRANSCRIPT=$(speak-to-ai transcript 2>/dev/null || echo "")

        # Check if transcript is available
        if [ -z "$TRANSCRIPT" ] || echo "$TRANSCRIPT" | grep -qi "no transcript available"; then
            notify "音声が認識できませんでした（無音または短すぎる録音）"
            exit 0
        fi

        # Copy to clipboard and store in clipman
        if command -v wl-copy >/dev/null 2>&1; then
            printf "%s" "$TRANSCRIPT" | wl-copy
            # Also store in clipman history
            if command -v clipman >/dev/null 2>&1; then
                printf "%s" "$TRANSCRIPT" | clipman store --no-persist
            fi
        fi

        # Restore DND state
        if [ -f "$DND_STATE_FILE" ]; then
            DND_WAS_ON=$(cat "$DND_STATE_FILE")
            if [ "$DND_WAS_ON" = "false" ]; then
                # DND was off before, turn it off again
                swaync-client -df
            fi
            rm -f "$DND_STATE_FILE"
        fi

        # In active_window mode, daemon types automatically - no notification needed
    else
        # Not recording - start recording

        # Save current DND state and enable DND
        DND_STATUS=$(swaync-client -D)
        if [ "$DND_STATUS" = "true" ]; then
            echo "true" > "$DND_STATE_FILE"
        else
            echo "false" > "$DND_STATE_FILE"
            # Enable DND for recording
            swaync-client -dn
        fi

        set +e  # Temporarily disable exit on error
        START_RESULT=$(speak-to-ai start 2>&1)
        START_EXIT=$?
        set -e

        if [ $START_EXIT -ne 0 ]; then
            notify "エラー: $(echo "$START_RESULT" | head -n 1)"
            # Restore DND state on error
            if [ -f "$DND_STATE_FILE" ]; then
                DND_WAS_ON=$(cat "$DND_STATE_FILE")
                if [ "$DND_WAS_ON" = "false" ]; then
                    swaync-client -df
                fi
                rm -f "$DND_STATE_FILE"
            fi
            exit 1
        fi
    fi
}

main "$@"
