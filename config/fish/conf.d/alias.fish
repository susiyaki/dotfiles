# ============================================================
# Aliases and Abbreviations
# ============================================================

alias relogin="fish"

# Git
abbr g git

# Docker
abbr d docker
abbr dc docker-compose

# fzf
abbr f fzf

# ni (Node.js runner)
alias nrd="nr dev"
alias nrb="nr build"
alias nrs="nr start"

# Safe file operations
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias mkdir="mkdir -p"

# Enable aliases after sudo
alias sudo="sudo "

# Editor (nvim and tmux are managed by Nix)
alias vim="tmux new-window nvim"
alias vi="tmux new-window nvim"

# eza (managed by Nix)
alias ls="eza"
alias la="eza -a"
alias ll="eza -l"

# bat (managed by Nix)
alias cat="bat"

# htop (managed by Nix)
alias top="htop"
