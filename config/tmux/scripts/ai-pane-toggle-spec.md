# AI Pane Toggle Script 仕様書

## 概要

`ai-pane-toggle.sh` は、tmux環境でAI Assistantペインを管理するスクリプトです。Neovimインスタンスごとに独立したAIペインを作成・管理し、必要に応じてAI専用セッションに退避させることができます。

## 環境変数

### 入力パラメータ

- `AI_ASSISTANT`: 使用するAI Assistant（`claude` `gemini` または `codex`）
  - 未設定の場合は `tmux show-environment -g AI_ASSISTANT` から取得
- `AI_ACTION`: 実行するアクション（デフォルト: `toggle`）
  - `toggle`: AIペインの表示/非表示を切り替え
  - `open`: AIペインを開く（既に存在する場合は何もしない）
- `NVIM_INSTANCE_ID`: Neovimインスタンスの一意なID（Neovimから実行時）
- `NVIM_CWD`: Neovimの現在の作業ディレクトリ（新規AIペイン作成時）

### tmuxペインオプション

- `@nvim_instance_id`: NeovimペインのインスタンスID
- `@ai_pane_marker`: AIペインの識別マーカー（形式: `ai_pane_{NVIM_ID}`）

## 動作モード

### 1. Neovimペインから実行（`@nvim_instance_id`が設定されている場合）

#### 1-1. 現在のウィンドウにAIペインが既に存在する場合

##### `ACTION=open`の場合
- 何もせず終了（AIペインを維持）
- 用途: Neovimの`,,`キーマップからfloatingウィンドウを開く際、既存のAIペインを保持

##### `ACTION=toggle`の場合
- AIペインをAI専用セッション（`ai-{ASSISTANT}`）に移動
- 手順:
  1. AI専用セッションが存在しない場合は作成
  2. AIペインを独立したウィンドウに分離（`break-pane`）
  3. そのウィンドウをAI専用セッションに移動（`move-window`）

#### 1-2. AI専用セッションにAIペインが存在する場合
- AIペインを現在のウィンドウに持ってくる
- 手順:
  1. AI専用セッションから対応するAIペイン（`@ai_pane_marker`が一致）を検索
  2. `join-pane`で水平分割して持ってくる

#### 1-3. AIペインが存在しない場合

##### `ACTION=open`の場合
- 新しいAIペインを作成
- 手順:
  1. 作業ディレクトリを`NVIM_CWD`または現在のペインのパスから取得
  2. AI Assistantに応じたコマンドを実行（`claude code` or `gemini-cli`）
  3. 水平分割（50%）で新しいペインを作成
  4. ペインに`@ai_pane_marker`と タイトルを設定
  5. フォーカスを元のペインに戻す

##### `ACTION=toggle`の場合
- エラーメッセージを表示（AIペインが見つからない）

### 2. AIペインから実行（`@ai_pane_marker`が設定されている場合）

- AIペインをAI専用セッション（`ai-{ASSISTANT}`）に移動
- 手順は「1-1. ACTION=toggleの場合」と同じ

### 3. それ以外のペインから実行

- エラーメッセージを表示（Neovimペインまたは AIペインから実行してください）

## AI専用セッション

- セッション名: `ai-{ASSISTANT}` （例: `ai-claude`, `ai-gemini`）
- 目的: 現在使用していないAIペインを退避させる
- AIペインは各Neovimインスタンスごとに独立したウィンドウとして管理される

## 使用例

### tmuxキーバインドから（`C-q ,`）
```bash
# 環境変数でAI Assistantを設定
export AI_ASSISTANT=claude

# Neovimペインから実行 → AIペインを持ってくる/送る
# AIペインから実行 → AI専用セッションに送る
```

### Neovimキーマップから（`,,`）
```lua
vim.fn.jobstart(script_path, {
  env = {
    AI_ASSISTANT = "claude",
    NVIM_INSTANCE_ID = vim.fn.getpid(),
    NVIM_CWD = vim.fn.getcwd(),
    AI_ACTION = "open",  -- 既存のAIペインは維持
  },
})
```

## ペインの識別

### Neovimペインの識別
- `@nvim_instance_id`: Neovimプロセスの一意なID

### AIペインの識別
- `@ai_pane_marker`: `ai_pane_{NVIM_ID}` 形式
- ペインタイトル: `ai-{ASSISTANT}-nvim{NVIM_ID}` （例: `ai-claude-nvim12345`）

## エラーハンドリング

- AI専用セッションが存在しない場合 → 自動作成
- AIペインが見つからない場合 → エラーメッセージ表示（3秒間）
- ウィンドウIDの取得に失敗した場合 → 処理をスキップ

## 依存関係

- tmux
- bash
- awk, grep（ペイン情報の解析用）

## 制限事項

- 各Neovimインスタンスにつき1つのAIペインのみ管理可能
- AI専用セッションは手動で削除する必要がある
- AIペインを別のウィンドウに手動で移動した場合、スクリプトが追跡できなくなる可能性がある
