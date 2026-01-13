function git-worktree-cd --description 'Change directory to a worktree in git-worktrees/ using fzf'
    set -l repo_root (command git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$repo_root"
        echo "Error: Not in a git repository"
        return 1
    end

    set -l worktree_base_dir "$repo_root/git-worktrees"

    # git-worktreesディレクトリが存在しない場合
    if not test -d "$worktree_base_dir"
        echo "Error: git-worktrees directory not found"
        echo "Run 'git worktree init' to set up worktrees"
        return 1
    end

    # worktree一覧を "name (branch)" 形式で取得
    set -l worktree_list
    for dir in "$worktree_base_dir"/*
        if not test -d "$dir"
            continue
        end

        set -l dir_name (basename "$dir")

        # git worktree list からブランチ名を取得
        set -l branch_info (command git worktree list --porcelain | grep -A 2 "worktree $dir\$" | grep "^branch" | sed 's/^branch refs\/heads\///')

        if test -n "$branch_info"
            set -a worktree_list "$dir_name ($branch_info)"
        else
            # ブランチ情報が取得できない場合は名前のみ
            set -a worktree_list "$dir_name"
        end
    end

    if test (count $worktree_list) -eq 0
        echo "No worktrees found in git-worktrees/"
        return 0
    end

    set -l selected (printf "%s\n" $worktree_list | fzf \
        --height 40% \
        --reverse \
        --preview '' \
        --prompt "Select worktree: ")

    if test -z "$selected"
        echo "Cancelled."
        return 0
    end

    # "worktree_name (branch_name)" から worktree_name を抽出
    set -l worktree_name (string replace -r ' \(.*\)$' '' -- "$selected")
    cd "$worktree_base_dir/$worktree_name"
end
