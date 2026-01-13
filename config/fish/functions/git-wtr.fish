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
        --prompt "Select worktree to remove: " \
        --preview "cd {} && git status -s" \
        --preview-window=right:50%:wrap)

    if test -z "$selected"
        echo "Cancelled."
        return 0
    end

    # 削除確認
    echo ""
    echo "🗑️  About to remove worktree:"
    echo "   $selected"
    echo ""
    echo -n "Are you sure? [y/N] "
    read -l -P " › " confirm

    switch $confirm
        case Y y
            command git worktree remove "$selected"
            if test $status -eq 0
                echo "✅ Worktree removed: $selected"
            else
                echo ""
                echo "⚠️  Failed to remove. The worktree may have uncommitted changes."
                echo "To force remove, run: git worktree remove --force $selected"
            end
        case '*'
            echo "Cancelled."
    end
end
