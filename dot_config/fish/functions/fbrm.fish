function fbrm
    set -l branch (git branch --all | grep -v HEAD | fzf-tmux -p --preview-window="hidden")

    if test -n "$branch"
        git checkout (echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    end
end
