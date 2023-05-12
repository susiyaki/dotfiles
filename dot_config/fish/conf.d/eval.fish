eval (ssh-agent -c) >/dev/null

if [ (uname -s) = "Darwin" ]
    eval (/opt/homebrew/bin/brew shellenv) >/dev/null
else
    keychain -q $HOME/.ssh/github/id_rsa
    source $HOME/.keychain/(hostname)-fish
end

# nodenv
if type -q nodenv
    source (nodenv init - |psub)
end

# pyenv
if type -q pyenv
    status is-interactive; and pyenv init --path | source
    pyenv init - | source
    status --is-interactive; and source (pyenv virtualenv-init -|psub)
end

# rbenv
if type -q rbenv
    status --is-interactive; and rbenv init - fish | source
end

# jenv
if type -q jenv
    status --is-interactive; and source (jenv init -|psub)
end

# luaenv
if type -q luaenv
    status --is-interactive; and . (luaenv init -|psub)
end

# direnv
if type -q direnv
    eval (direnv hook fish | source)
end

# github cli
if type -q gh
    eval (gh completion -s fish | source)
end
