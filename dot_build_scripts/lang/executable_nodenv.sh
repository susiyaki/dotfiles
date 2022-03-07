#!/bin/bash

# https://github.com/nodenv/nodenv
# https://github.com/nodenv/node-build
if !(type "nodenv" > /dev/null 2>&1); then
  git clone https://github.com/nodenv/nodenv $HOME/.nodenv
  $HOME/.nodenv/bin/nodenv init
  if ! [ -d $OME/.nodenv/plugins ]; then
    mkdir $HOME/.nodenv/plugins
  fi
  git clone https://github.com/nodenv/node-build $HOME/.nodenv/plugins/node-build
else
  echo "nodenv was installed. Should relogin shell."
fi
