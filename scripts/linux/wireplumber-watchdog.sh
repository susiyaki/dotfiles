#!/bin/bash

# wireplumber CPU使用率監視スクリプト
# CPU使用率が閾値を超えたらwireplumberを再起動する

# 設定
CPU_THRESHOLD=80  # CPU使用率の閾値（1コアあたりの%）
CHECK_DURATION=10 # 連続してチェックする秒数
LOG_FILE="$HOME/.local/share/wireplumber-watchdog.log"
NUM_CORES=$(grep -c ^processor /proc/cpuinfo)  # CPU コア数を取得

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ログディレクトリを作成
mkdir -p "$(dirname "$LOG_FILE")"

# wireplumberのプロセスIDを取得
get_wireplumber_pid() {
    pgrep -u "$USER" wireplumber | head -n1
}

# グローバル変数: 前回の測定値
PREV_TOTAL=0
PREV_PROC=0
CPU_USAGE_RESULT=0

# CPU使用率を取得（/proc/statから計算、1秒間の使用率）
# 結果はCPU_USAGE_RESULTグローバル変数に格納
get_cpu_usage() {
    local pid=$1
    if [ -z "$pid" ]; then
        CPU_USAGE_RESULT=0
        PREV_TOTAL=0
        PREV_PROC=0
        return
    fi

    # プロセスが存在するか確認
    if [ ! -f "/proc/$pid/stat" ]; then
        CPU_USAGE_RESULT=0
        PREV_TOTAL=0
        PREV_PROC=0
        return
    fi

    # システム全体のCPU時間を取得
    local cpu_line=$(head -1 /proc/stat)
    local total1=$(echo "$cpu_line" | awk '{sum=$2+$3+$4+$5+$6+$7+$8; print sum}')

    # プロセスのCPU時間を取得 (utime + stime)
    local proc_stat=$(cat /proc/$pid/stat)
    local proc1=$(echo "$proc_stat" | awk '{print $14 + $15}')

    # 初回は測定のみ
    if [ "$PREV_TOTAL" -eq 0 ]; then
        PREV_TOTAL=$total1
        PREV_PROC=$proc1
        CPU_USAGE_RESULT=0
        return
    fi

    # 差分を計算
    local total_diff=$((total1 - PREV_TOTAL))
    local proc_diff=$((proc1 - PREV_PROC))

    # 更新
    PREV_TOTAL=$total1
    PREV_PROC=$proc1

    # CPU使用率を計算（%）: プロセスのCPU時間 / システムCPU時間 * コア数 * 100
    # 1コアあたりの使用率として返す
    if [ "$total_diff" -gt 0 ]; then
        CPU_USAGE_RESULT=$(awk -v proc="$proc_diff" -v total="$total_diff" -v cores="$NUM_CORES" \
            'BEGIN {printf "%.0f", (proc / total * cores * 100)}')
    else
        CPU_USAGE_RESULT=0
    fi
}

# デスクトップ通知を送信
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"  # normal, low, critical

    # DBUSセッションを確保
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        # systemd経由の場合、DBUSアドレスを取得
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    fi

    if command -v notify-send &> /dev/null; then
        notify-send \
            --urgency="$urgency" \
            --icon=dialog-warning \
            --app-name="WirePlumber Watchdog" \
            "$title" \
            "$message"
    fi
}

# wireplumberを再起動
restart_wireplumber() {
    local current_cpu=$1
    log_message "CPU使用率が${CPU_THRESHOLD}%を超えたため、wireplumberを再起動します (現在: ${current_cpu}%)"

    # 再起動前に通知を送信（再起動するとwatchdog自体も再起動されるため）
    send_notification \
        "WirePlumber 再起動実行" \
        "CPU使用率が${current_cpu}%に達しました。wireplumberを再起動します" \
        "normal"

    # 再起動を実行
    # 注: PartOf=pipewire-session-manager.serviceのため、watchdogも再起動される
    log_message "wireplumberサービスを再起動しています..."
    systemctl --user restart wireplumber.service

    # 以下のコードは実行されない可能性が高い（watchdogが再起動されるため）
    log_message "wireplumberの再起動コマンドが完了しました（終了コード: $?）"
}

# メイン処理
main() {
    log_message "監視を開始しました（閾値: ${CPU_THRESHOLD}% / 1コア、システム: ${NUM_CORES}コア）"

    local high_cpu_count=0
    local loop_count=0

    while true; do
        loop_count=$((loop_count + 1))
        pid=$(get_wireplumber_pid)

        if [ -z "$pid" ]; then
            log_message "警告: wireplumberプロセスが見つかりません"
            sleep 30
            continue
        fi

        get_cpu_usage "$pid"
        cpu_usage=$CPU_USAGE_RESULT

        if [ "$cpu_usage" -ge "$CPU_THRESHOLD" ]; then
            high_cpu_count=$((high_cpu_count + 1))
            log_message "高CPU使用率を検出: ${cpu_usage}% / 1コア (${high_cpu_count}/${CHECK_DURATION}秒)"

            if [ "$high_cpu_count" -ge "$CHECK_DURATION" ]; then
                restart_wireplumber "$cpu_usage"
                high_cpu_count=0
                # 再起動後は少し長めに待機
                sleep 30
            fi
        else
            if [ "$high_cpu_count" -gt 0 ]; then
                log_message "CPU使用率が正常に戻りました: ${cpu_usage}% / 1コア"
            fi
            high_cpu_count=0
        fi

        sleep 1
    done
}

# スクリプトを実行
main
