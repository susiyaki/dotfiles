#!/usr/bin/env bash
# claude_confirm.sh — Home Assistant 経由でユーザー確認を取るライブラリ
#
# 使い方:
#   chmod +x claude_confirm.sh
#
#   # ライブラリとして読み込む
#   source ./claude_confirm.sh
#   result=$(request_user_confirmation "READ_FILE" "app.config.ts を読んでよいですか？" "app.config.ts")
#
#   # 直接実行するとデモが走る
#   ./claude_confirm.sh
#
# 環境変数:
#   HA_WEBHOOK_URL               Webhook URL (default: http://homeassistant:8123/api/webhook/claude_code_hook)
#   CLAUDE_CONFIRM_RESULT_FILE   結果 JSON のパス (default: /tmp/claude_confirm_result.json)
#   CLAUDE_CONFIRM_TIMEOUT_SEC   タイムアウト秒数 (default: 300)
#   CLAUDE_CONFIRM_POLL_SEC      ポーリング間隔秒数 (default: 5)

set -euo pipefail

# ============================================================
#  依存チェック
# ============================================================

_cc_check_deps() {
  local missing=()
  local cmd
  for cmd in curl jq date sleep; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    printf 'claude_confirm: missing required commands: %s\n' "${missing[*]}" >&2
    return 1
  fi
}
_cc_check_deps || exit 1

# ============================================================
#  設定
# ============================================================

: "${HA_WEBHOOK_URL:=http://homeassistant:8123/api/webhook/claude_code_hook}"
: "${CLAUDE_CONFIRM_RESULT_FILE:=/tmp/claude_confirm_result.json}"
: "${CLAUDE_CONFIRM_TIMEOUT_SEC:=300}"
: "${CLAUDE_CONFIRM_POLL_SEC:=5}"

# ============================================================
#  ユーティリティ
# ============================================================

# 一意なリクエスト ID を生成 (epoch_秒_RANDOM)
_cc_generate_request_id() {
  printf 'req_%s_%s%s' "$(date +%s)" "$RANDOM" "$RANDOM"
}

# 現在時刻をエポックミリ秒で返す
_cc_epoch_ms() {
  local ns
  ns="$(date +%s%N 2>/dev/null || echo '')"
  if [[ ${#ns} -ge 19 ]]; then
    # date +%s%N が使える環境 (Linux)
    echo $(( ns / 1000000 ))
  else
    echo $(( $(date +%s) * 1000 ))
  fi
}

# ============================================================
#  コア: request_user_confirmation
# ============================================================
# Usage:
#   result=$(request_user_confirmation ACTION_ID MESSAGE [PATH])
#
# 標準出力: "ok" / "ng" / "timeout"
# 終了コード: 0=ok  1=ng  2=timeout

request_user_confirmation() {
  local action_id="${1:?Usage: request_user_confirmation ACTION_ID MESSAGE [PATH]}"
  local message="${2:?Usage: request_user_confirmation ACTION_ID MESSAGE [PATH]}"
  local path="${3:-}"

  # --- リクエスト ID & 送信時刻 ---
  local request_id start_ms
  request_id="$(_cc_generate_request_id)"
  start_ms="$(_cc_epoch_ms)"

  # --- Webhook 送信 ---
  local payload
  payload="$(jq -nc \
    --arg title   "Claude Code: 確認要求" \
    --arg message "$message" \
    --arg action  "$action_id" \
    --arg path    "$path" \
    --arg reqid   "$request_id" \
    '{
      title:      $title,
      message:    $message,
      action_id:  $action,
      path:       $path,
      request_id: $reqid
    }'
  )"

  printf '[confirm] POST %s  request_id=%s\n' "$HA_WEBHOOK_URL" "$request_id" >&2

  local http_code
  http_code="$(
    curl -s -o /dev/null -w '%{http_code}' -m 10 \
      -H 'Content-Type: application/json' \
      -d "$payload" \
      "$HA_WEBHOOK_URL" 2>/dev/null || echo '000'
  )"

  if [[ "$http_code" != "200" && "$http_code" != "201" && "$http_code" != "204" ]]; then
    printf '[confirm] webhook failed (HTTP %s) — treating as timeout\n' "$http_code" >&2
    echo "timeout"
    return 2
  fi

  printf '[confirm] webhook sent — waiting for response (timeout=%ss)\n' "$CLAUDE_CONFIRM_TIMEOUT_SEC" >&2

  # --- ポーリング ---
  local elapsed=0

  while [[ "$elapsed" -lt "$CLAUDE_CONFIRM_TIMEOUT_SEC" ]]; do
    sleep "$CLAUDE_CONFIRM_POLL_SEC"
    elapsed=$(( elapsed + CLAUDE_CONFIRM_POLL_SEC ))

    # ファイルが無い or 読めないならスキップ
    [[ -r "$CLAUDE_CONFIRM_RESULT_FILE" ]] || continue

    # 結果ファイルを 1 回の jq で全フィールド取得
    local parsed
    parsed="$(
      jq -r '
        [
          (.request_id  // ""),
          (.action_id   // ""),
          (.path        // ""),
          (.result      // ""),
          (.timestamp   // 0 | tostring)
        ] | join("\t")
      ' "$CLAUDE_CONFIRM_RESULT_FILE" 2>/dev/null || echo ''
    )"
    [[ -n "$parsed" ]] || continue

    local f_reqid f_action f_path f_result f_ts
    IFS=$'\t' read -r f_reqid f_action f_path f_result f_ts <<< "$parsed"

    # 一致チェック
    [[ "$f_reqid"  == "$request_id" ]] || continue
    [[ "$f_action" == "$action_id"  ]] || continue
    if [[ -n "$path" ]]; then
      [[ "$f_path" == "$path" ]] || continue
    fi

    # タイムスタンプが送信時刻より新しいか
    [[ "$f_ts" -ge "$start_ms" ]] 2>/dev/null || continue

    # --- 結果確定 ---
    case "$f_result" in
      ok)
        printf '[confirm] result=ok (%ss)\n' "$elapsed" >&2
        echo "ok"
        return 0
        ;;
      ng)
        printf '[confirm] result=ng (%ss)\n' "$elapsed" >&2
        echo "ng"
        return 1
        ;;
      *)
        printf '[confirm] unknown result "%s" — treating as ng\n' "$f_result" >&2
        echo "ng"
        return 1
        ;;
    esac
  done

  printf '[confirm] timed out after %ss\n' "$CLAUDE_CONFIRM_TIMEOUT_SEC" >&2
  echo "timeout"
  return 2
}

# ============================================================
#  便利ラッパー
# ============================================================

confirm_read_file() {
  local path="${1:?Usage: confirm_read_file PATH}"
  local result
  result="$(request_user_confirmation "READ_FILE" "${path} を読んでよいですか？" "$path")" || true

  case "$result" in
    ok)
      echo "ユーザーが許可しました: $path"
      cat "$path"
      ;;
    ng)
      echo "ユーザーが拒否しました。スキップします: $path" >&2
      return 1
      ;;
    timeout)
      echo "タイムアウト。スキップします: $path" >&2
      return 2
      ;;
    *)
      echo "不明な結果: $result" >&2
      return 2
      ;;
  esac
}

confirm_write_file() {
  local path="${1:?Usage: confirm_write_file PATH}"
  local result
  result="$(request_user_confirmation "WRITE_FILE" "${path} に書き込んでよいですか？" "$path")" || true

  case "$result" in
    ok)
      echo "ユーザーが許可しました: $path"
      ;;
    ng)
      echo "ユーザーが拒否しました。スキップします: $path" >&2
      return 1
      ;;
    timeout)
      echo "タイムアウト。スキップします: $path" >&2
      return 2
      ;;
    *)
      echo "不明な結果: $result" >&2
      return 2
      ;;
  esac
}

confirm_exec() {
  local cmd_desc="${1:?Usage: confirm_exec DESCRIPTION}"
  local result
  result="$(request_user_confirmation "EXEC" "${cmd_desc} を実行してよいですか？")" || true

  case "$result" in
    ok)
      echo "ユーザーが許可しました: $cmd_desc"
      ;;
    ng)
      echo "ユーザーが拒否しました。スキップします: $cmd_desc" >&2
      return 1
      ;;
    timeout)
      echo "タイムアウト。スキップします: $cmd_desc" >&2
      return 2
      ;;
    *)
      echo "不明な結果: $result" >&2
      return 2
      ;;
  esac
}

# ============================================================
#  デモ (直接実行時のみ)
# ============================================================

_cc_demo() {
  echo "=== claude_confirm.sh デモ ==="
  echo ""
  echo "設定:"
  echo "  HA_WEBHOOK_URL             = $HA_WEBHOOK_URL"
  echo "  CLAUDE_CONFIRM_RESULT_FILE = $CLAUDE_CONFIRM_RESULT_FILE"
  echo "  CLAUDE_CONFIRM_TIMEOUT_SEC = $CLAUDE_CONFIRM_TIMEOUT_SEC"
  echo "  CLAUDE_CONFIRM_POLL_SEC    = $CLAUDE_CONFIRM_POLL_SEC"
  echo ""

  local result
  result="$(request_user_confirmation \
    "READ_FILE" \
    "high-climb/app.config.ts を読んでよいですか？" \
    "high-climb/app.config.ts"
  )" || true

  echo ""
  echo "結果: $result"
}

# source されたときはデモを実行しない
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  _cc_demo
fi
