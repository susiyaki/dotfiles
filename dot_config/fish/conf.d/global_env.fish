# Language
set -x LANG ja_JP.UTF-8

# Editor
set -x EDITOR "nvim"

# PATH
set -gx PATH /usr/local/sbin $PATH
# mysql client
test -d /usr/local/opt/mysql-client/bin && set -gx PATH /usr/local/opt/mysql-client/bin $PATH
# rust
test -d $HOME/.cargo/bin && set -gx PATH $HOME/.cargo/bin $PATH
# flutter
test -d $HOME/.flutter/bin && set -gx PATH $HOME/.flutter/bin $PATH
test -d $HOME/.flutter/.pub-cache/bin && set -gx PATH $HOME/.flutter/.pub-cache/bin $PATH
# dart
if test -f $HOME/.dvm/scripts/dvm
  sh $HOME/.dvm/scripts/dvm
end
# dart-sdk
test -d $HOME/.flutter/bin/cache/dart-sdk/bin && set -gx PATH $HOME/.flutter/bin/cache/dart-sdk/bin $PATH

# nodenv
test -d $HOME/.nodenv && set -gx PATH $HOME/.nodenv/bin $HOME/.nodenv/shims $PATH
# pyenv
test -d $HOME/.pyenv && set -gx PYENV_ROOT $HOME/.pyenv
test -d $PYENV_ROOT && set -gx PATH $PYENV_ROOT/bin $HOME/.pyenv/shims $PATH
# rbenv
test -d $HOME/.rbenv && set -gx PATH $HOME/.rbenv/bin $HOME/.rbenv/shims $PATH
# jenv
test -d $HOME/.jenv && set -gx PATH $HOME/.jenv/bin $PATH
# luaenv
test -d $HOME/.luaenv/bin && set -gx PATH $HOME/.luaenv/bin $PATH
# fvm
test -d $HOME/.pub-cache/bin && set -gx PATH $HOME/.pub-cache/bin $PATH
test -d $HOME/fvm/default/bin && set -gx PATH $HOME/fvm/default/bin $PATH
# go
test -d /usr/local/go && set -gx GOROOT /usr/local/go
test -d $GOROOT/bin && set -gx PATH $GOROOT/bin $PATH
test -d $HOME/go/bin && set -gx PATH $HOME/go/bin $PATH
# android
test -d /lib/android-sdk/tools && set -gx PATH /lib/android-sdk/tools $PATH
test -d /lib/android-sdk/tools/bin && set -gx PATH /lib/android-sdk/tools/bin $PATH
test -d /lib/android-sdk/platform-tools && set -gx PATH /lib/android-sdk/platform-tools $PATH
test -d $HOME/Library/Android/sdk/tools && set -gx PATH $HOME/Library/Android/sdk/tools $PATH
test -d $HOME/Library/Android/sdk/tools/bin && set -gx PATH $HOME/Library/Android/sdk/tools/bin $PATH
test -d $HOME/Library/Android/sdk/platform-tools && set -gx PATH $HOME/Library/Android/sdk/platform-tools $PATH
test -d $HOME/Android/Sdk/tools && set -gx PATH $HOME/Android/Sdk/tools $PATH
test -d $HOME/Android/Sdk/tools/bin && set -gx PATH $HOME/Android/Sdk/tools/bin $PATH
test -d $HOME/Android/Sdk/platform-tools && set -gx PATH $HOME/Android/Sdk/platform-tools $PATH
test -d /Users/laeno/Library/Android/sdk && set -gx ANDROID_HOME /Users/laeno/Library/Android/sdk

# openssl
test -d /usr/local/opt/openssl@1.1/bin && set -gx PATH /usr/local/opt/openssl@1.1/bin $PATH
test -d /usr/local/opt/openssl@1.1 && set -gx PATH /usr/local/opt/openssl@1.1/bin $PATH
