#!/bin/bash

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
SCREENCAST_DIR="$HOME/Pictures/Screencasts"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)

# Helper function to detect second click (no time limit)
is_double_click() {
    local CLICK_FILE="$1"

    if [ -f "$CLICK_FILE" ]; then
        # Second click detected, remove file
        rm -f "$CLICK_FILE"
        return 0
    fi

    # First click, create marker file
    touch "$CLICK_FILE"
    return 1
}

# Restore DND state
restore_dnd() {
    local DND_STATE_FILE="$1"
    if [ -f "$DND_STATE_FILE" ]; then
        DND_WAS_ON=$(cat "$DND_STATE_FILE")
        if [ "$DND_WAS_ON" = "false" ]; then
            swaync-client -df
        fi
        rm -f "$DND_STATE_FILE"
    fi
}

# Functions
screenshot_to_clipboard() {
    local CLICK_FILE="/tmp/screenshot-clipboard-click"
    local FLAG_FILE="/tmp/screenshot-clipboard-double-click-flag"

    if is_double_click "$CLICK_FILE"; then
        # Set flag to suppress cancellation from first click
        touch "$FLAG_FILE"
        # Cancel any existing area selection
        pkill -9 slurp 2>/dev/null
        sleep 0.1
        # Full screen
        grim - | wl-copy
        notify-send -t 2000 "Screenshot" "Full screen copied to clipboard"
        rm -f "$FLAG_FILE"
    else
        # Area selection
        GEOMETRY=$(slurp -d)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" - | wl-copy
            notify-send -t 2000 "Screenshot" "Screenshot copied to clipboard"
            # Success - clean up click file
            rm -f "$CLICK_FILE"
        else
            # Cancelled - clean up click file
            rm -f "$CLICK_FILE"
            # Only show cancelled if not a double-click
            if [ ! -f "$FLAG_FILE" ]; then
                notify-send -t 2000 "Screenshot" "Cancelled"
            fi
        fi
    fi
}

screenshot_to_file() {
    local CLICK_FILE="/tmp/screenshot-file-click"
    local FLAG_FILE="/tmp/screenshot-file-double-click-flag"
    FILE="$SCREENSHOT_DIR/screenshot-$TIMESTAMP.png"
    mkdir -p "$SCREENSHOT_DIR"

    if is_double_click "$CLICK_FILE"; then
        # Set flag to suppress cancellation from first click
        touch "$FLAG_FILE"
        # Cancel any existing area selection
        pkill -9 slurp 2>/dev/null
        sleep 0.1
        # Full screen
        grim "$FILE"
        notify-send -t 2000 "Screenshot" "Full screen saved:\n$FILE"
        rm -f "$FLAG_FILE"
    else
        # Area selection
        GEOMETRY=$(slurp -d)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILE"
            notify-send -t 2000 "Screenshot" "Screenshot saved:\n$FILE"
            # Success - clean up click file
            rm -f "$CLICK_FILE"
        else
            # Cancelled - clean up click file
            rm -f "$CLICK_FILE"
            # Only show cancelled if not a double-click
            if [ ! -f "$FLAG_FILE" ]; then
                notify-send -t 2000 "Screenshot" "Cancelled"
            fi
        fi
    fi
}

screencast_toggle() {
    MODE="$1"  # "clipboard" or "save"
    MODE_FILE="/tmp/screencast-mode.lock"
    DND_STATE_FILE="/tmp/screencast-dnd-state.lock"

    if pgrep -x wf-recorder > /dev/null; then
        # Stop recording
        killall -s SIGINT wf-recorder
        sleep 0.5  # Wait for file to be finalized

        # Restore DND state
        restore_dnd "$DND_STATE_FILE"

        LATEST_FILE=$(ls -t "$SCREENCAST_DIR"/screencast-*.mp4 2>/dev/null | head -n1)

        # Read mode from file if not specified (e.g., stopped from waybar)
        if [ -z "$MODE" ] && [ -f "$MODE_FILE" ]; then
            MODE=$(cat "$MODE_FILE")
        fi

        if [ "$MODE" = "clipboard" ]; then
            # Copy to clipboard
            if [ -n "$LATEST_FILE" ]; then
                printf "file://%s" "$LATEST_FILE" | wl-copy --type text/uri-list
                notify-send -t 2000 "Screen Recording" "Recording stopped\nVideo copied to clipboard"
            else
                notify-send -t 2000 "Screen Recording" "Recording stopped"
            fi
        else
            # Save only (no clipboard)
            if [ -n "$LATEST_FILE" ]; then
                notify-send -t 2000 "Screen Recording" "Recording stopped\nSaved: $LATEST_FILE"
            else
                notify-send -t 2000 "Screen Recording" "Recording stopped"
            fi
        fi

        # Clean up mode file
        rm -f "$MODE_FILE"
    else
        # Start recording with double-click detection
        local CLICK_FILE="/tmp/screencast-click"
        local FLAG_FILE="/tmp/screencast-double-click-flag"
        mkdir -p "$SCREENCAST_DIR"
        OUTPUT_FILE="$SCREENCAST_DIR/screencast-$TIMESTAMP.mp4"

        # Save current DND state and enable DND
        DND_STATUS=$(swaync-client -D)
        if [ "$DND_STATUS" = "true" ]; then
            echo "true" > "$DND_STATE_FILE"
        else
            echo "false" > "$DND_STATE_FILE"
            # Enable DND for recording
            swaync-client -dn
        fi

        if is_double_click "$CLICK_FILE"; then
            # Set flag to suppress cancellation from first click
            touch "$FLAG_FILE"
            # Cancel any existing area selection
            pkill -9 slurp 2>/dev/null
            sleep 0.1
            # Save mode for later reference
            echo "$MODE" > "$MODE_FILE"
            # Full screen recording
            wf-recorder -f "$OUTPUT_FILE" &
            notify-send -t 2000 "Screen Recording" "Full screen recording started"
            rm -f "$FLAG_FILE"
        else
            # Area selection
            GEOMETRY=$(slurp -d)
            if [ -n "$GEOMETRY" ]; then
                # Save mode for later reference
                echo "$MODE" > "$MODE_FILE"
                wf-recorder -g "$GEOMETRY" -f "$OUTPUT_FILE" &
                notify-send -t 2000 "Screen Recording" "Recording started"
                # Success - clean up click file
                rm -f "$CLICK_FILE"
            else
                # Recording cancelled, clean up click file
                rm -f "$CLICK_FILE"
                # Restore DND state
                restore_dnd "$DND_STATE_FILE"
                # Only show cancelled if not a double-click
                if [ ! -f "$FLAG_FILE" ]; then
                    notify-send -t 2000 "Screen Recording" "Cancelled"
                fi
            fi
        fi
    fi
}

# Main
case "$1" in
    screenshot)
        case "$2" in
            --clipboard) screenshot_to_clipboard ;;
            --save) screenshot_to_file ;;
            *) echo "Usage: $0 screenshot [--clipboard|--save]"; exit 1 ;;
        esac
        ;;
    screencast)
        case "$2" in
            --clipboard) screencast_toggle "clipboard" ;;
            --save) screencast_toggle "save" ;;
            *)
                # No mode specified, check if recording is running
                if pgrep -x wf-recorder > /dev/null; then
                    screencast_toggle ""
                else
                    echo "Usage: $0 screencast [--clipboard|--save]"
                    exit 1
                fi
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 {screenshot|screencast} [--clipboard|--save]"
        exit 1
        ;;
esac
