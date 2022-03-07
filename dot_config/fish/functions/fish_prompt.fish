function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    # PWD
    echo -n (set_color -o)" » "
    echo -n (set_color yellow)(prompt_pwd)
    set_color normal

    echo

    if not test $last_status -eq 0
        set_color $fish_color_error
    end

    echo -n '➤ '

    set_color normal
end
