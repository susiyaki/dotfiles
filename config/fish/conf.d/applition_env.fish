# ============================================================
# Application Environment Variables
# ============================================================
# Note: Basic env vars (LANG, EDITOR, XDG_*, ANDROID_*) are
# managed by Home Manager. This file contains app-specific
# runtime configurations.

# fzf
set -x FZF_DEFAULT_COMMAND "rg --files --hidden --follow --no-ignore-vcs --follow \
  -g '!node_modules/*' \
  -g '!.git/*' \
"
set -x FZF_DEFAULT_OPTS "--preview 'bat --color=always --theme=gruvbox-dark --style=numbers,header --line-range :100 {}' \
  --bind 'ctrl-y:execute: echo {} | pbcopy' \
  --bind 'ctrl-o:execute: tmux new-window nvim {}'
"
set -x FZF_ALT_C_OPTS "--preview 'tree -C {} | head -200'"
