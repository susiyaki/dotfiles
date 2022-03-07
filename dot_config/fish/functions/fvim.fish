function fvim
    set -l selected_file (git ls-files | fzf-tmux -p --preview-window="hidden")
    if test -n "$selected_file"
        vim $selected_file
    end
end
