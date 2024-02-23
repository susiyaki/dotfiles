# android
test -d /lib/android-sdk && set -x ANDROID_HOME "/lib/android-sdk" && set -x ANDROID_SDK_ROOT "$ANDROID_HOME"

test -d $HOME/Library/Android/sdk && set -x ANDROID_HOME "$HOME/Library/Android/sdk" && set -x ANDROID_SDK_ROOT "$ANDROID_HOME"

test -d $HOME/Android/Sdk && set -x ANDROID_HOME "$HOME/Android/Sdk" && set -x ANDROID_SDK_ROOT "$ANDROID_HOME"

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
