# Language
set -x LANG ja_JP.UTF-8

# Editor
set -x EDITOR "nvim"

# XDG
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x XDG_CACHE_HOME "$HOME/.cache"
set -x XDG_DATA_HOME "$HOME/.local/share"
set -x XDG_STATE_HOME "$HOME/.local/state"
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_CACHE_HOME
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_STATE_HOME

# go
set -x GOPATH "$XDG_DATA_HOME/go"
set -x PATH "$PATH:$GOPATH/bin"

# rust
set -x RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -x CARGO_HOME "$XDG_DATA_HOME/cargo"
test -d $CARGO_HOME && bass source "$CARGO_HOME/env"

# Android
set -x ANDROID_HOME "/opt/android-sdk"
