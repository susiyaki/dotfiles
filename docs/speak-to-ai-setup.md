# Speak to AI - 日本語音声入力セットアップ

Arch Linux（Sway + Alacritty + Neovim）環境で、日本語の音声をローカル Whisper でテキスト化し、任意のウィンドウに挿入する仕組み。

## 概要

- **音声認識**: whisper.cpp（完全ローカル、プライバシーフレンドリー）
- **モデル**: ggml-small-q8_0 (日本語対応、252MB)
- **対象環境**: Wayland (Sway), PipeWire/PulseAudio
- **入力先**: Neovim, ブラウザ (Claude Code, Perplexity), その他あらゆるアプリ

## セットアップ手順

### 1. パッケージのインストール

```bash
# AUR から speak-to-ai をインストール
yay -S speak-to-ai
```

### 2. Whisper モデルのダウンロード

```bash
# dotfiles ディレクトリから実行
./scripts/linux/setup-whisper.sh
```

または手動でダウンロード:
```bash
mkdir -p ~/.local/share/speak-to-ai/models
curl -L -o ~/.local/share/speak-to-ai/models/ggml-small-q8_0.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small-q8_0.bin
```

### 3. Home Manager の再ビルド

```bash
# dotfiles の変更を適用
home-manager switch --flake ~/dotfiles
```

または NixOS の場合:
```bash
sudo nixos-rebuild switch --flake ~/dotfiles
```

### 4. Sway の再起動

```bash
# Sway を再読み込み
$mod+Shift+c

# または完全に再起動
```

## 使い方

### 基本操作

1. **音声入力開始**: `$super+Shift+v` (Super = Windows キー)
2. **話す**: マイクに向かって日本語で話す
3. **音声入力停止**: もう一度 `$super+Shift+v` を押す
4. **自動入力**: 認識されたテキストが現在のウィンドウに自動入力される

### トグル動作

- **1回目**: 録音開始（通知: "録音開始"）
- **2回目**: 録音停止 → テキスト変換 → 自動入力（通知: "入力完了"）

### 対応アプリケーション

- **Neovim** (Alacritty 内)
  - INSERT モード中に音声入力すると、カーソル位置に挿入
  - コマンドモード、検索、コメントなど、どこでも使用可能

- **ブラウザ** (Chrome, Firefox など)
  - Claude Code のプロンプト入力欄
  - Perplexity の検索欄
  - その他、テキスト入力欄全般

- **その他**
  - ターミナル (Alacritty, その他)
  - Slack, Discord などのチャットアプリ
  - あらゆるテキスト入力可能なアプリ

## 設定

### 設定ファイル

`~/.config/speak-to-ai/config.yaml`

```yaml
model:
  path: "/home/YOUR_USERNAME/.local/share/speak-to-ai/models/ggml-small-q8_0.bin"
  language: "ja"  # 日本語固定
  threads: 0      # 0 = 自動検出

audio:
  sample_rate: 16000
  device: ""      # 空 = デフォルトマイク

output:
  method: "type"  # "type" = キーボード入力, "clipboard" = クリップボード
  auto_paste: false

recording:
  max_duration: 30        # 最大録音時間（秒）
  silence_threshold: 0.0  # 無音検知の閾値（0 = 無効）
  silence_duration: 2.0   # 無音継続時間（秒）
```

### カスタマイズ

#### ホットキーの変更

`~/dotfiles/config/sway/config`:
```sway
# デフォルト: $super+Shift+v
bindsym $super+Shift+v exec bash ~/.config/sway/scripts/speak-to-ai-input.sh

# 例: Ctrl+Alt+Space に変更
bindsym Control+Mod1+space exec bash ~/.config/sway/scripts/speak-to-ai-input.sh
```

#### モデルの変更

より高精度なモデルを使用する場合:
```bash
# Medium モデル (769MB, より高精度)
curl -L -o ~/.local/share/speak-to-ai/models/ggml-medium-q8_0.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium-q8_0.bin
```

設定ファイルのパスを更新:
```yaml
model:
  path: "/home/YOUR_USERNAME/.local/share/speak-to-ai/models/ggml-medium-q8_0.bin"
```

#### マイクデバイスの指定

デフォルト以外のマイクを使用する場合:
```bash
# 利用可能なデバイスを確認
pactl list sources short
```

設定ファイルで指定:
```yaml
audio:
  device: "alsa_input.pci-0000_64_00.6.HiFi__Mic1__source"
```

## トラブルシューティング

### 音声が認識されない

1. **マイクの確認**:
   ```bash
   pactl list sources short
   # マイクが認識されているか確認
   ```

2. **マイクのテスト**:
   ```bash
   arecord -d 5 test.wav  # 5秒間録音
   aplay test.wav         # 再生して確認
   ```

3. **speak-to-ai のログ確認**:
   ```bash
   speak-to-ai status
   journalctl --user -u speak-to-ai -f
   ```

### デーモンが起動しない

1. **手動起動**:
   ```bash
   speak-to-ai -config ~/.config/speak-to-ai/config.yaml -debug
   ```

2. **モデルファイルの確認**:
   ```bash
   ls -lh ~/.local/share/speak-to-ai/models/
   # ggml-small-q8_0.bin が約 252MB であることを確認
   ```

### テキストが入力されない

1. **wtype の確認**:
   ```bash
   command -v wtype
   # /usr/bin/wtype が表示されるはず
   ```

2. **手動テスト**:
   ```bash
   echo "テストテキスト" | wtype -
   ```

3. **クリップボードモードを試す**:
   設定ファイルで `method: "clipboard"` に変更

### 権限エラー

```bash
# input グループの確認
groups | grep input

# 追加が必要な場合
sudo usermod -aG input $USER
# 再ログインが必要
```

## ユースケース例

### Neovim でのコード記述

```
1. INSERT モードで $super+Shift+v
2. 「ユーザー認証機能を実装する関数を作成」と話す
3. 自動的にコメントとして挿入される
```

### Claude Code への指示

```
1. ブラウザの入力欄にフォーカス
2. $super+Shift+v で録音開始
3. 「データベースのマイグレーションスクリプトを作成して、
   ユーザーテーブルに email_verified カラムを追加してください」
4. 長文の指示が自動入力される
```

### Perplexity での調査

```
1. Perplexity の検索欄にフォーカス
2. $super+Shift+v
3. 「Rust の async/await と tokio の使い方について教えてください」
4. 質問が自動入力されて検索開始
```

## 技術詳細

### アーキテクチャ

```
┌─────────────┐
│ ホットキー  │  $super+Shift+v
│ (Sway)      │
└──────┬──────┘
       │
       v
┌─────────────────────────┐
│ speak-to-ai-input.sh    │
│ - デーモン管理          │
│ - 録音制御              │
│ - トランスクリプト取得  │
└──────┬──────────────────┘
       │
       v
┌─────────────────────────┐
│ speak-to-ai daemon      │
│ - 音声録音 (PipeWire)   │
│ - Whisper 処理          │
│ - IPC (Unix socket)     │
└──────┬──────────────────┘
       │
       v
┌─────────────────────────┐
│ whisper.cpp             │
│ - ggml-small-q8_0       │
│ - 日本語認識            │
└──────┬──────────────────┘
       │
       v
┌─────────────────────────┐
│ wtype / wl-clipboard    │
│ - キーボード入力        │
│ - クリップボード操作    │
└─────────────────────────┘
```

### ファイル構成

```
dotfiles/
├── config/
│   ├── sway/
│   │   ├── config              # Sway 設定 (keybinding含む)
│   │   └── scripts/
│   │       └── speak-to-ai-input.sh  # 音声入力スクリプト
│   └── speak-to-ai/
│       └── config.yaml         # speak-to-ai 設定
├── modules/
│   └── archlinux/
│       └── sway/
│           └── default.nix     # Nix モジュール
├── scripts/
│   └── setup-whisper-model.sh  # モデルセットアップ
└── docs/
    └── speak-to-ai-setup.md    # このファイル
```

## 参考リンク

- [speak-to-ai GitHub](https://github.com/speak-to-ai/speak-to-ai)
- [whisper.cpp GitHub](https://github.com/ggerganov/whisper.cpp)
- [Whisper Models](https://huggingface.co/ggerganov/whisper.cpp)
