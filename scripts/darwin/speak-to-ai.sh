#!/usr/bin/env bash
# Mac用音声入力スクリプト (Whisper + AppleScript)
# Option+V で起動し、録音→文字起こし→自動入力を実行

set -euo pipefail

# Karabinerから実行される際の環境変数設定
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# 設定
RECORD_DIR="$HOME/.local/share/whisper-recordings"
STATE_FILE="$RECORD_DIR/recording.state"
AUDIO_FILE="$RECORD_DIR/recording.wav"
MODEL_PATH="$HOME/.local/share/whisper.cpp/models/ggml-medium-q5_0.bin"
WHISPER_BIN="$(brew --prefix whisper-cpp 2>/dev/null)/bin/whisper-cli"
# Fallback: brewのbinディレクトリから検索
if [ ! -f "$WHISPER_BIN" ]; then
    WHISPER_BIN="$(brew --prefix)/bin/whisper-cli"
fi
LOG_FILE="$RECORD_DIR/speak-to-ai.log"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# 通知関数（terminal-notifierを優先、fallbackでosascript）
notify() {
    local message="$1"
    local title="${2:-Whisper}"
    local sound="${3:-}"

    log "通知: $message"

    if command -v terminal-notifier >/dev/null 2>&1; then
        if [ -n "$sound" ]; then
            terminal-notifier -title "$title" -message "$message" -sound "$sound"
        else
            terminal-notifier -title "$title" -message "$message"
        fi
    else
        if [ -n "$sound" ]; then
            osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null || true
        else
            osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
        fi
    fi
}

# ディレクトリ作成
mkdir -p "$RECORD_DIR"

# すべての出力をログにリダイレクト（Karabinerからの実行時用）
exec 2>>"$LOG_FILE"

# ロックファイルで多重起動を防止
LOCK_FILE="$RECORD_DIR/speak-to-ai.lock"
LOCK_PID_FILE="$RECORD_DIR/speak-to-ai.pid"

# 既存のロックを確認
if [ -f "$LOCK_FILE" ]; then
    if [ -f "$LOCK_PID_FILE" ]; then
        OLD_PID=$(cat "$LOCK_PID_FILE")
        if ps -p "$OLD_PID" > /dev/null 2>&1; then
            log "既に実行中です (PID: $OLD_PID)。終了します。"
            exit 0
        else
            log "古いロックファイルを削除します"
            rm -f "$LOCK_FILE" "$LOCK_PID_FILE"
        fi
    fi
fi

# ロックを取得
echo $$ > "$LOCK_PID_FILE"
touch "$LOCK_FILE"

# スクリプト終了時にロックを削除
trap "rm -f $LOCK_FILE $LOCK_PID_FILE" EXIT

log "=== スクリプト開始 (PID: $$) ==="
log "PATH: $PATH"
log "WHISPER_BIN: $WHISPER_BIN"

# 録音状態を確認
if [ -f "$STATE_FILE" ]; then
    # 録音停止 - 即座に通知（音付き）
    log "録音停止"
    if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "Whisper" -message "音声を文字起こし中..." -sound "Glass"
    else
        osascript -e "display notification \"音声を文字起こし中...\" with title \"Whisper\" sound name \"Glass\"" 2>/dev/null || true
    fi
    log "通知: 音声を文字起こし中..."

    RECORDING_PID=$(cat "$STATE_FILE")
    log "録音プロセス停止 (PID: $RECORDING_PID)"

    # sox のプロセスを終了
    if ps -p "$RECORDING_PID" > /dev/null 2>&1; then
        log "録音プロセスにSIGINTを送信"
        kill -INT "$RECORDING_PID"

        # プロセスが完全に終了するまで待機（最大3秒）
        for i in {1..30}; do
            if ! ps -p "$RECORDING_PID" > /dev/null 2>&1; then
                log "録音プロセスが正常に終了しました（${i}0ms後）"
                break
            fi
            sleep 0.1
        done

        # まだ動いている場合は強制終了
        if ps -p "$RECORDING_PID" > /dev/null 2>&1; then
            log "警告: プロセスが終了しないため強制終了します"
            kill -9 "$RECORDING_PID"
            sleep 0.5
        fi
    else
        log "警告: 録音プロセスが既に終了しています"
    fi

    # soxがファイルを完全に書き込むまで待機
    sleep 1

    # ファイルのヘッダーを検証・修復（必須）
    log "ファイルヘッダーの検証中"
    FILE_DURATION=$(soxi -D "$AUDIO_FILE" 2>/dev/null || echo "0")
    log "録音ファイルの長さ（ヘッダー）: $FILE_DURATION 秒"

    # 0秒または300秒を超える場合はヘッダー破損
    if (( $(echo "$FILE_DURATION == 0 || $FILE_DURATION > 300" | bc -l) )); then
        log "ヘッダーが破損しています（$FILE_DURATION秒）。修復します。"

        # soxで再エンコードして修復
        TEMP_FILE="$RECORD_DIR/recording_fixed.wav"
        if sox "$AUDIO_FILE" -r 16000 -c 1 -b 16 "$TEMP_FILE" 2>/dev/null; then
            mv "$TEMP_FILE" "$AUDIO_FILE"
            log "ファイルを修復しました"

            # 修復後の長さを確認
            FIXED_DURATION=$(soxi -D "$AUDIO_FILE" 2>/dev/null || echo "0")
            log "修復後の長さ: $FIXED_DURATION 秒"
        else
            log "エラー: ファイル修復に失敗しました"
            rm -f "$TEMP_FILE"
            notify "録音ファイルの修復に失敗しました" "Whisper" "Basso"
            exit 1
        fi
    else
        log "ヘッダーは正常です"
    fi

    rm "$STATE_FILE"

    log "文字起こし開始"

    # 音声ファイルが存在するか確認
    if [ ! -f "$AUDIO_FILE" ]; then
        log "エラー: 録音ファイルが見つかりません"
        notify "録音ファイルが見つかりません" "Whisper" "Basso"
        exit 1
    fi

    # 録音ファイルのサイズと更新時刻を確認
    AUDIO_SIZE=$(stat -f%z "$AUDIO_FILE" 2>/dev/null || echo "0")
    AUDIO_MTIME=$(stat -f%Sm -t "%Y-%m-%d %H:%M:%S" "$AUDIO_FILE" 2>/dev/null || echo "unknown")
    log "録音ファイルサイズ: $AUDIO_SIZE bytes"
    log "録音ファイル更新時刻: $AUDIO_MTIME"
    log "録音ファイルパス: $AUDIO_FILE"

    if [ "$AUDIO_SIZE" -lt 1000 ]; then
        log "エラー: 録音ファイルが小さすぎます"
        notify "録音が正しく行われませんでした" "Whisper" "Basso"
        rm -f "$AUDIO_FILE"
        exit 1
    fi

    # 10MB（約60秒）を超える場合は異常
    if [ "$AUDIO_SIZE" -gt 10000000 ]; then
        log "エラー: 録音ファイルが大きすぎます ($AUDIO_SIZE bytes)"
        notify "録音が異常に長すぎます" "Whisper" "Basso"
        rm -f "$AUDIO_FILE"
        exit 1
    fi

    # Whisper で文字起こし
    if [ ! -f "$WHISPER_BIN" ]; then
        log "エラー: whisper-cpp が見つかりません"
        notify "whisper-cpp がインストールされていません" "Whisper" "Basso"
        exit 1
    fi

    # 文字起こし実行（日本語、出力形式はテキストのみ）
    log "Whisper実行開始: $WHISPER_BIN -m $MODEL_PATH -l ja --no-timestamps -otxt -of $RECORD_DIR/output $AUDIO_FILE"

    "$WHISPER_BIN" \
        -m "$MODEL_PATH" \
        -l ja \
        --no-timestamps \
        -otxt \
        -of "$RECORD_DIR/output" \
        "$AUDIO_FILE" 2>&1 | tee -a "$LOG_FILE"

    # テキストファイルから取得（whisper.cpp は .txt ファイルを出力する）
    if [ -f "$RECORD_DIR/output.txt" ]; then
        log "output.txtの内容: $(cat $RECORD_DIR/output.txt)"
        TEXT=$(cat "$RECORD_DIR/output.txt" | grep -v '^\[' | sed '/^$/d' | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ //;s/ $//')
        log "処理後のテキスト: $TEXT"
        rm "$RECORD_DIR/output.txt"
    else
        log "エラー: output.txtが生成されませんでした"
        TEXT=""
    fi

    # テキストが空の場合
    if [ -z "$TEXT" ]; then
        log "エラー: テキストが空です"
        notify "音声を認識できませんでした" "Whisper" "Basso"
        rm -f "$AUDIO_FILE"
        exit 1
    fi

    log "文字起こし成功: $TEXT"

    # テキストを入力
    # クリップボード経由で入力（日本語対応）
    ORIGINAL_CLIPBOARD=$(pbpaste 2>/dev/null || echo "")

    # UTF-8でクリップボードにコピー
    printf "%s" "$TEXT" | pbcopy

    # 少し待機
    sleep 0.2

    # Cmd+Vで貼り付け
    osascript -e 'tell application "System Events" to keystroke "v" using command down' 2>&1 | tee -a "$LOG_FILE"

    # 元のクリップボードに戻す
    sleep 0.3
    printf "%s" "$ORIGINAL_CLIPBOARD" | pbcopy

    log "入力完了"
    # 入力完了の通知（音なし）
    notify "入力完了: ${TEXT:0:50}..."

    # クリーンアップ（確実に削除）
    log "クリーンアップ開始"
    rm -f "$AUDIO_FILE"
    rm -f "$RECORD_DIR/output.txt"
    rm -f "$RECORD_DIR/temp_text.txt"
    log "クリーンアップ完了"

else
    # 録音開始
    log "録音開始"

    # 古いファイルを削除（キャッシュ問題を防ぐ）
    if [ -f "$AUDIO_FILE" ]; then
        OLD_SIZE=$(stat -f%z "$AUDIO_FILE" 2>/dev/null || echo "0")
        OLD_MTIME=$(stat -f%Sm -t "%Y-%m-%d %H:%M:%S" "$AUDIO_FILE" 2>/dev/null || echo "unknown")
        log "古い録音ファイルを削除: $AUDIO_FILE (サイズ: $OLD_SIZE bytes, 更新時刻: $OLD_MTIME)"
        rm -f "$AUDIO_FILE"
        if [ -f "$AUDIO_FILE" ]; then
            log "警告: 録音ファイルの削除に失敗しました"
        else
            log "録音ファイルを削除しました"
        fi
    else
        log "古い録音ファイルは存在しません"
    fi
    if [ -f "$RECORD_DIR/output.txt" ]; then
        log "古いoutput.txtを削除"
        rm -f "$RECORD_DIR/output.txt"
    fi

    # 録音開始の通知（音付き）
    if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "Whisper" -message "録音開始（もう一度 Option+V で停止）" -sound "Ping"
    else
        osascript -e "display notification \"録音開始（もう一度 Option+V で停止）\" with title \"Whisper\" sound name \"Ping\"" 2>/dev/null || true
    fi
    log "通知: 録音開始（もう一度 Option+V で停止）"

    # sox で録音開始（バックグラウンド）
    # パイプラインを使わず、直接ファイルに書き込む
    if command -v sox >/dev/null 2>&1; then
        # sox を使用（推奨）
        log "録音コマンド実行: rec -c 1 -r 16000 $AUDIO_FILE trim 0 300"

        # ログリダイレクトなしで実行（ファイルヘッダーの破損を防ぐ）
        rec -c 1 -r 16000 "$AUDIO_FILE" trim 0 300 >/dev/null 2>&1 &
        RECORDING_PID=$!
        log "録音プロセス開始 (PID: $RECORDING_PID, 最大300秒)"
    else
        log "エラー: sox が見つかりません"
        notify "sox がインストールされていません" "Whisper" "Basso"
        exit 1
    fi

    # PID を保存
    echo "$RECORDING_PID" > "$STATE_FILE"

    # 録音プロセスが正常に開始されたか確認
    sleep 0.2
    if ps -p "$RECORDING_PID" > /dev/null 2>&1; then
        log "録音プロセスが正常に動作しています (PID: $RECORDING_PID)"
    else
        log "エラー: 録音プロセスが開始に失敗しました"
        rm -f "$STATE_FILE"
        notify "録音の開始に失敗しました" "Whisper" "Basso"
        exit 1
    fi

    # 録音ファイルが作成され始めるまで待機
    for i in {1..10}; do
        if [ -f "$AUDIO_FILE" ]; then
            log "録音ファイルが作成されました"
            break
        fi
        sleep 0.1
    done
fi
