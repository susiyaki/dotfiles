# Speak to AI - Mac用音声入力セットアップ

Mac (Darwin) 環境で、日本語の音声をローカル Whisper でテキスト化し、任意のウィンドウに挿入する仕組み。

## 概要

- **音声認識**: whisper.cpp（完全ローカル、プライバシーフレンドリー）
- **モデル**: ggml-medium-q5_0 (日本語対応、540MB)
- **対象環境**: macOS (Darwin)
- **キーバインド**: Karabiner-Elements + Option+V
- **入力先**: Neovim, ブラウザ (Claude Code, Perplexity), その他あらゆるアプリ

## セットアップ手順

### 1. Nix でパッケージをインストール

```bash
# darwin-rebuild で必要なパッケージを自動インストール
darwin-rebuild switch --flake ~/dotfiles#m1-mac
```

これにより以下がインストールされます：
- `whisper-cpp` - Whisper音声認識
- `sox` - 音声録音ツール
- `karabiner-elements` - キーバインドカスタマイズ
- Karabiner設定（Option+V のキーバインド含む）

### 2. Whisper モデルのダウンロード

```bash
# dotfiles ディレクトリから実行
./scripts/darwin/setup-whisper.sh
```

このスクリプトは以下を実行します：
- 必要なパッケージが存在するか確認
- Whisper モデルのダウンロード
- マイクアクセス権限の案内

または手動でダウンロード：

```bash
# モデルディレクトリを作成
mkdir -p ~/.local/share/whisper.cpp/models

# Medium モデルをダウンロード（540MB、日本語対応）
curl -L -o ~/.local/share/whisper.cpp/models/ggml-medium-q5_0.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium-q5_0.bin
```

### 3. マイクアクセス権限の設定

初回起動時、以下のアプリにマイクアクセス権限を付与してください：

1. **システム設定** > **プライバシーとセキュリティ** > **マイク**
2. 以下にチェックを入れる：
   - `karabiner_console_user_server`
   - `Terminal`（または使用しているターミナルアプリ）
   - `bash`

## 使い方

### 基本操作

1. **音声入力開始**: `Option+V`
2. **話す**: マイクに向かって日本語で話す
3. **音声入力停止**: もう一度 `Option+V` を押す
4. **自動入力**: 認識されたテキストが現在のウィンドウに自動入力される

### トグル動作

- **1回目**: 録音開始（通知: "録音開始"）
- **2回目**: 録音停止 → テキスト変換 → 自動入力（通知: "入力完了"）

### 対応アプリケーション

- **Neovim** (Alacritty 内)
  - INSERT モード中に音声入力すると、カーソル位置に挿入
  - コマンドモード、検索、コメントなど、どこでも使用可能

- **ブラウザ** (Chrome, Firefox, Safari など)
  - Claude Code のプロンプト入力欄
  - Perplexity の検索欄
  - その他、テキスト入力欄全般

- **その他**
  - ターミナル (Alacritty, iTerm2, その他)
  - Slack, Discord などのチャットアプリ
  - あらゆるテキスト入力可能なアプリ

## トラブルシューティング

### 音声が認識されない

1. **マイクの確認**:
   ```bash
   # 録音テスト（5秒間）
   rec -c 1 -r 16000 test.wav trim 0 5

   # 再生して確認
   play test.wav
   ```

2. **マイクアクセス権限の確認**:
   - システム設定 > プライバシーとセキュリティ > マイク
   - 必要なアプリにチェックが入っているか確認

3. **Whisper モデルの確認**:
   ```bash
   ls -lh ~/.local/share/whisper.cpp/models/
   # ggml-medium-q5_0.bin が約 540MB であることを確認
   ```

### キーバインドが動作しない

1. **Karabiner-Elements の起動確認**:
   - メニューバーに Karabiner-Elements のアイコンがあるか確認

2. **設定の確認**:
   - Karabiner-Elements の設定画面を開く
   - "Complex Modifications" タブで "Option+V でWhisper音声入力" が有効か確認

3. **ログの確認**:
   ```bash
   tail -f /var/log/karabiner/console_user_server.log
   ```

### テキストが入力されない

1. **AppleScript の権限確認**:
   - システム設定 > プライバシーとセキュリティ > アクセシビリティ
   - `System Events` にチェックが入っているか確認

2. **手動テスト**:
   ```bash
   osascript -e 'tell application "System Events" to keystroke "test"'
   ```

### 録音ファイルが見つからない

録音ファイルは以下に保存されます：
```bash
~/.local/share/whisper-recordings/recording.wav
```

問題がある場合は、ディレクトリが存在するか確認：
```bash
ls -la ~/.local/share/whisper-recordings/
```

## カスタマイズ

### キーバインドの変更

Option+V 以外のキーに変更したい場合、`config/karabiner/karabiner.json` を編集：

```json
{
  "description": "Ctrl+Shift+V でWhisper音声入力",
  "manipulators": [
    {
      "from": {
        "key_code": "v",
        "modifiers": {
          "mandatory": ["control", "shift"]
        }
      },
      "to": [
        {
          "shell_command": "/bin/bash $HOME/dotfiles/scripts/darwin/speak-to-ai.sh"
        }
      ],
      "type": "basic"
    }
  ]
}
```

### モデルの変更

より高精度なモデルを使用する場合:

```bash
# Large モデル (1.5GB, 最高精度)
curl -L -o ~/.local/share/whisper.cpp/models/ggml-large-q5_0.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-q5_0.bin
```

スクリプト内のパスを更新:
```bash
# scripts/darwin/speak-to-ai.sh を編集
MODEL_PATH="$HOME/.local/share/whisper.cpp/models/ggml-large-q5_0.bin"
```

### 録音設定の変更

録音の品質や形式を変更する場合、`scripts/darwin/speak-to-ai.sh` を編集：

```bash
# サンプルレート変更（デフォルト: 16000Hz）
rec -c 1 -r 44100 "$AUDIO_FILE"

# ステレオ録音
rec -c 2 -r 16000 "$AUDIO_FILE"
```

## ファイル構成

```
dotfiles/
├── config/
│   └── karabiner/
│       └── karabiner.json        # Karabiner 設定 (Option+V 含む)
├── scripts/
│   └── darwin/
│       ├── setup-whisper.sh      # セットアップスクリプト
│       └── speak-to-ai.sh        # 音声入力スクリプト
└── docs/
    └── speak-to-ai-darwin.md     # このファイル
```

## 技術詳細

### アーキテクチャ

```
┌─────────────┐
│ Option+V    │  Karabiner-Elements
│ (キー入力) │
└──────┬──────┘
       │
       v
┌─────────────────────────┐
│ speak-to-ai.sh          │
│ - 録音制御 (sox)        │
│ - トランスクリプト生成  │
│ - AppleScript実行       │
└──────┬──────────────────┘
       │
       v
┌─────────────────────────┐
│ whisper-cpp             │
│ - ggml-medium-q5_0      │
│ - 日本語認識            │
└──────┬──────────────────┘
       │
       v
┌─────────────────────────┐
│ AppleScript             │
│ - System Events         │
│ - keystroke 実行        │
└─────────────────────────┘
```

### 録音フロー

1. **開始**: Option+V → `rec` コマンド起動（バックグラウンド）
2. **録音中**: PID を `~/.local/share/whisper-recordings/recording.state` に保存
3. **停止**: Option+V → `rec` プロセスを kill
4. **変換**: `whisper-cli` で音声をテキスト化
5. **入力**: AppleScript で `keystroke` 実行

### 使用技術

- **whisper.cpp**: C/C++ 実装の Whisper、CPU でも高速
- **sox**: 録音ツール（`rec` コマンド）
- **Karabiner-Elements**: キーバインドカスタマイズ
- **AppleScript**: システムレベルのキー入力

## 参考リンク

- [whisper.cpp GitHub](https://github.com/ggerganov/whisper.cpp)
- [Whisper Models](https://huggingface.co/ggerganov/whisper.cpp)
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
- [SoX - Sound eXchange](http://sox.sourceforge.net/)
