function git --description 'Git wrapper with worktree enhancements'
    # git wta - インタラクティブなworktree作成
    if test "$argv[1]" = "wta"
        # 引数なし：インタラクティブモード
        if test (count $argv) -eq 1
            git-wta
            return $status
        # 引数あり：通常のgit worktree add（拡張機能付き）
        else
            __git_worktree_add $argv[2..-1]
            return $status
        end
    end

    # git wtr - インタラクティブなworktree削除
    if test "$argv[1]" = "wtr"
        # 引数なし：インタラクティブモード
        if test (count $argv) -eq 1
            git-wtr
            return $status
        # 引数あり：通常のgit worktree remove
        else
            command git worktree remove $argv[2..-1]
            return $status
        end
    end

    # git worktree サブコマンドの拡張
    if test "$argv[1]" = "worktree"
        # git worktree init - カスタムコマンド
        if test "$argv[2]" = "init"
            __git_worktree_init
            return $status

        # git worktree add - 拡張機能
        else if test "$argv[2]" = "add"
            __git_worktree_add $argv[3..-1]
            return $status
        end
    end

    # その他のgitコマンドはそのまま実行
    command git $argv
end

function __git_worktree_init --description 'Initialize git-worktrees configuration'
    set -l repo_root (command git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$repo_root"
        echo "Error: Not in a git repository"
        return 1
    end

    set -l worktree_dir "$repo_root/git-worktrees"
    set -l config_file "$worktree_dir/config"
    set -l exclude_file "$repo_root/.git/info/exclude"

    # git-worktrees ディレクトリを作成
    if not test -d "$worktree_dir"
        mkdir -p "$worktree_dir"
        echo "✓ Created directory: git-worktrees/"
    else
        echo "✓ Directory already exists: git-worktrees/"
    end

    # config ファイルを作成
    if not test -f "$config_file"
        # テンプレートがあればコピー、なければデフォルトを作成
        if test -f "$worktree_dir/config.template"
            cp "$worktree_dir/config.template" "$config_file"
            echo "✓ Created config from template: git-worktrees/config"
        else
            echo "# Worktree間で共有するファイルのリスト
# 相対パス（リポジトリルートからの）で指定してください
# 空行と#で始まる行は無視されます

# 環境変数ファイル
.env.local

# Claude Code設定
.claude/settings.local.json
" > "$config_file"
            echo "✓ Created config: git-worktrees/config"
        end
    else
        echo "✓ Config already exists: git-worktrees/config"
    end

    # .git/info/exclude に追記
    if not test -f "$exclude_file"
        mkdir -p (dirname "$exclude_file")
        touch "$exclude_file"
    end

    if not grep -q "^git-worktrees/\*" "$exclude_file" 2>/dev/null
        echo "" >> "$exclude_file"
        echo "# git-worktrees configuration (added by git worktree init)" >> "$exclude_file"
        echo "git-worktrees/*" >> "$exclude_file"
        echo "✓ Added git-worktrees/* to .git/info/exclude"
    else
        echo "✓ git-worktrees/* already in .git/info/exclude"
    end

    echo ""
    echo "✅ Git worktree configuration initialized!"
    echo ""
    echo "Next steps:"
    echo "  1. Edit git-worktrees/config to specify files to share"
    echo "  2. Run: git worktree add <path> <branch>"
end

function __git_worktree_add --description 'Add worktree with automatic symlink setup'
    set -l repo_root (command git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$repo_root"
        echo "Error: Not in a git repository"
        return 1
    end

    # 通常の git worktree add を実行
    command git worktree add $argv
    set -l git_status $status

    if test $git_status -ne 0
        return $git_status
    end

    # worktreeのパスを取得（最初の引数）
    set -l worktree_path $argv[1]

    # 相対パスを絶対パスに変換
    set worktree_path (realpath "$worktree_path")

    # config ファイルが存在するかチェック
    set -l config_file "$repo_root/git-worktrees/config"

    if not test -f "$config_file"
        echo ""
        echo "⚠️  git-worktrees/config not found. Run 'git worktree init' to set up."
        return 0
    end

    # シンボリックリンクを作成
    echo ""
    echo "🔗 Setting up symlinks for shared files..."

    set -l linked_count 0

    # config ファイルを読んで、各ファイルへのシンボリックリンクを作成
    while read -l line
        # 空行とコメント行をスキップ
        if test -z "$line"; or string match -q "#*" "$line"
            continue
        end

        set -l source_file "$repo_root/$line"
        set -l target_file "$worktree_path/$line"

        if test -e "$source_file"
            # ターゲットディレクトリを作成
            set -l target_dir (dirname "$target_file")
            mkdir -p "$target_dir"

            # 既存のファイルがある場合は削除
            if test -e "$target_file"
                rm -rf "$target_file"
            end

            # シンボリックリンクを作成
            ln -s "$source_file" "$target_file"
            echo "  ✓ Linked: $line"
            set linked_count (math $linked_count + 1)
        else
            echo "  ⚠ Skipped (not found): $line"
        end
    end < "$config_file"

    echo ""
    if test $linked_count -gt 0
        echo "✅ Worktree created with $linked_count symlink(s)"
    else
        echo "✅ Worktree created (no symlinks created)"
    end

    return 0
end
