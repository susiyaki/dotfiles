function git-wta --description 'Interactive git worktree add'
    set -l repo_root (command git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$repo_root"
        echo "Error: Not in a git repository"
        return 1
    end

    set -l worktree_base_dir "$repo_root/git-worktrees"

    # ディレクトリ名を入力
    echo "📁 Create new worktree"
    echo ""
    echo "Directory name (will be created at git-worktrees/[name]): "
    read -l -P " › " dir_name

    if test -z "$dir_name"
        echo "Cancelled."
        return 0
    end

    set -l worktree_path "$worktree_base_dir/$dir_name"

    # すでに存在する場合はエラー
    if test -e "$worktree_path"
        echo "Error: Directory already exists: $worktree_path"
        return 1
    end

    echo ""
    echo "🌿 Branch selection"
    echo "  1) Use existing branch"
    echo "  2) Create new branch"
    echo ""
    echo "Select mode [1/2]: "
    read -l -P " › " branch_mode

    switch $branch_mode
        case 1
            # 既存ブランチを選択
            set -l branches (command git branch -a --format='%(refname:short)' | sed 's|^origin/||' | sort -u)

            if test (count $branches) -eq 0
                echo "Error: No branches found"
                return 1
            end

            set -l selected_branch (printf "%s\n" $branches | fzf \
                --height 40% \
                --reverse \
                --prompt "Select branch: " \
                --preview "git log --oneline --graph --color=always {} | head -20" \
                --preview-window=right:60%:wrap)

            if test -z "$selected_branch"
                echo "Cancelled."
                return 0
            end

            echo ""
            echo "Creating worktree..."
            echo "  Path: $worktree_path"
            echo "  Branch: $selected_branch"
            echo ""

            # worktreeを作成（git.fishの__git_worktree_addを呼ぶため、gitコマンド経由で実行）
            command git worktree add "$worktree_path" "$selected_branch"
            set -l status_code $status

            if test $status_code -eq 0
                # シンボリックリンクを作成（__git_worktree_addの処理を手動実行）
                __create_worktree_symlinks "$worktree_path"
            end

            return $status_code

        case 2
            # 新しいブランチを作成
            echo ""
            echo -n "New branch name: "
            read -l -P " › " new_branch

            if test -z "$new_branch"
                echo "Cancelled."
                return 0
            end

            # ベースブランチを選択
            echo ""
            echo "Select base branch:"
            set -l branches (command git branch -a --format='%(refname:short)' | sed 's|^origin/||' | sort -u)

            set -l base_branch (printf "%s\n" $branches | fzf \
                --height 40% \
                --reverse \
                --prompt "Select base branch: " \
                --preview "git log --oneline --graph --color=always {} | head -20" \
                --preview-window=right:60%:wrap)

            if test -z "$base_branch"
                echo "Cancelled."
                return 0
            end

            echo ""
            echo "Creating worktree..."
            echo "  Path: $worktree_path"
            echo "  New branch: $new_branch"
            echo "  Base branch: $base_branch"
            echo ""

            # worktreeを作成
            command git worktree add -b "$new_branch" "$worktree_path" "$base_branch"
            set -l status_code $status

            if test $status_code -eq 0
                # シンボリックリンクを作成
                __create_worktree_symlinks "$worktree_path"
            end

            return $status_code

        case '*'
            echo "Invalid selection."
            return 1
    end
end

function __create_worktree_symlinks --description 'Create symlinks for shared files in worktree'
    set -l worktree_path $argv[1]
    set -l repo_root (command git rev-parse --show-toplevel 2>/dev/null)
    set -l config_file "$repo_root/git-worktrees/config"

    if not test -f "$config_file"
        echo ""
        echo "⚠️  git-worktrees/config not found. Skipping symlink creation."
        return 0
    end

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
end
