#!/bin/bash

# https://github.com/rbenv/rbenv
if !(type "rbenv" > /dev/null 2>&1); then
  git clone https://github.com/rbenv/rbenv $HOME/.rbenv
  cd ~/.rbenv && src/configure && make -C src
  $HOME/.rbenv/bin/rbenv init
  if ! [ -d $OME/.rbenv/plugins ]; then
    mkdir $HOME/.rbenv/plugins
  fi
  git clone https://github.com/rbenv/ruby-build $HOME/.rbenv/plugins/ruby-build
  echo "rbenv was installed. Should relogin shell."
fi
