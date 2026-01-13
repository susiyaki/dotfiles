function git-wtr --description 'Interactive git worktree remove using fzf'
    set -l repo_root (command git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$repo_root"
        echo "Error: Not in a git repository"
        return 1
    end

    # worktree一覧を取得（メインを除く）
    set -l worktrees (command git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2 | tail -n +2)

    if test (count $worktrees) -eq 0
        echo "No additional worktrees found."
        return 0
    end

    # fzfで選択
    set -l selected (printf "%s\n" $worktrees | fzf \
        --height 40% \
        --reverse \
        --preview '' \
        --prompt "Select worktree to remove: ")

    if test -z "$selected"
        echo "Cancelled."
        return 0
    end

    # 削除確認
    echo ""
    echo "🗑️  About to remove worktree:"
    echo "   $selected"
    echo ""
    echo "Are you sure? [y/N] "
    read -l -P " › " confirm

    switch $confirm
        case Y y
            # cleanup フックスクリプトの権限チェック
            set -l cleanup_script "$repo_root/git-worktrees/cleanup"
            if test -f "$cleanup_script"; and not test -x "$cleanup_script"
                echo "Error: git-worktrees/cleanup exists but is not executable"
                echo "Run: chmod +x git-worktrees/cleanup"
                return 1
            end

            command git worktree remove "$selected"
            if test $status -eq 0
                echo "✅ Worktree removed: $selected"

                # cleanup フックスクリプトがあれば実行
                set -l cleanup_script "$repo_root/git-worktrees/cleanup"
                if test -f "$cleanup_script"; and test -x "$cleanup_script"
                    echo ""
                    echo "🔧 Running cleanup hook..."
                    bash "$cleanup_script" "$selected"
                    set -l cleanup_status $status

                    if test $cleanup_status -eq 0
                        echo "✅ Cleanup hook completed successfully"
                    else
                        echo "⚠️  Cleanup hook failed with status $cleanup_status"
                    end
                end
            else
                echo ""
                echo "⚠️  Failed to remove. The worktree may have uncommitted changes."
                echo "To force remove, run: git worktree remove --force $selected"
            end
        case '*'
            echo "Cancelled."
    end
end
