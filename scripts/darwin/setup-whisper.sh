#!/usr/bin/env bash
# Mac用 Whisper音声入力セットアップスクリプト
#
# 前提条件：
#   - darwin-rebuild switch --flake ~/dotfiles#m1-mac でパッケージがインストール済み
#     (whisper-cpp, sox, karabiner-elements)
#
# このスクリプトは以下を実行します：
# 1. 必要なパッケージが存在するか確認
# 2. Whisperモデルのダウンロード
# 3. マイクアクセス権限の案内

set -euo pipefail

echo "=== Mac用 Whisper音声入力セットアップ ==="
echo ""

# 必要なパッケージの確認
echo "=== 必要なパッケージの確認 ==="
echo ""

REQUIRED_COMMANDS=("whisper-cli" "sox" "rec")
MISSING_COMMANDS=()

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✓ $cmd が見つかりました"
    else
        MISSING_COMMANDS+=("$cmd")
    fi
done

if [ ${#MISSING_COMMANDS[@]} -gt 0 ]; then
    echo ""
    echo "❌ 以下のコマンドが見つかりません: ${MISSING_COMMANDS[*]}"
    echo ""
    echo "以下のコマンドでパッケージをインストールしてください："
    echo "  darwin-rebuild switch --flake ~/dotfiles#m1-mac"
    exit 1
fi

# Karabiner-Elements の確認
if [ -d "/Applications/Karabiner-Elements.app" ]; then
    echo "✓ Karabiner-Elements はインストール済み"
else
    echo "⚠️  Karabiner-Elements がインストールされていません"
    echo "   以下のコマンドでインストールしてください："
    echo "     darwin-rebuild switch --flake ~/dotfiles#m1-mac"
fi

echo ""

# Whisperモデルのダウンロード
MODEL_DIR="$HOME/.local/share/whisper.cpp/models"
MODEL_NAME="ggml-medium-q5_0.bin"
MODEL_PATH="$MODEL_DIR/$MODEL_NAME"
MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/$MODEL_NAME"

echo "=== Whisperモデルのダウンロード ==="
echo ""

mkdir -p "$MODEL_DIR"

if [ -f "$MODEL_PATH" ]; then
    echo "✓ モデルは既にダウンロード済みです"
    MODEL_SIZE=$(du -h "$MODEL_PATH" | cut -f1)
    echo "  場所: $MODEL_PATH"
    echo "  サイズ: $MODEL_SIZE"
else
    echo "モデルをダウンロードしています: $MODEL_NAME"
    echo "サイズ: 約540MB"
    echo ""

    if curl -L --progress-bar -o "$MODEL_PATH" "$MODEL_URL"; then
        echo ""
        echo "✓ モデルのダウンロードが完了しました"
        MODEL_SIZE=$(du -h "$MODEL_PATH" | cut -f1)
        echo "  場所: $MODEL_PATH"
        echo "  サイズ: $MODEL_SIZE"
    else
        echo ""
        echo "❌ モデルのダウンロードに失敗しました"
        exit 1
    fi
fi

echo ""

# Karabiner設定の確認
echo "=== Karabiner設定の確認 ==="
echo ""

KARABINER_CONFIG="$HOME/.config/karabiner/karabiner.json"

if [ -f "$KARABINER_CONFIG" ] || [ -L "$KARABINER_CONFIG" ]; then
    echo "✓ Karabiner設定が見つかりました"
    echo "  Option+V のキーバインディングはNixで管理されています"
else
    echo "⚠️  Karabiner設定が見つかりません"
    echo "   darwin-rebuild switch を実行してください"
fi

echo ""

# マイクアクセス権限の確認
echo "=== マイクアクセス権限の確認 ==="
echo ""
echo "⚠️  初回起動時、以下のアプリにマイクアクセス権限を付与してください："
echo "   - karabiner_console_user_server"
echo "   - Terminal (または使用しているターミナルアプリ)"
echo "   - bash"
echo ""
echo "設定方法："
echo "   システム設定 > プライバシーとセキュリティ > マイク"
echo ""

# 完了メッセージ
echo "=== セットアップ完了 ==="
echo ""
echo "✓ 全ての設定が完了しました！"
echo ""
echo "使い方："
echo "  1. Karabiner-Elementsが起動していることを確認"
echo "  2. Option+V で録音開始"
echo "  3. 話す"
echo "  4. Option+V で録音停止（自動的に文字起こし→入力）"
echo ""
echo "注意事項："
echo "  - 初回起動時は、マイクアクセス権限を許可してください"
echo "  - Karabiner-Elementsの設定でOption+Vが有効になっているか確認してください"
echo ""
