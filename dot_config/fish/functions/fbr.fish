function fbr
    set -l branch (git branch -vv | fzf-tmux -p --preview-window="hidden")

    if test -n "$branch"
        git checkout (echo "$branch" | awk '{print $1}' | sed "s/.* //")
    end
end
