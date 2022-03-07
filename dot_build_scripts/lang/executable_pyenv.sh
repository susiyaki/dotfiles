#!/bin/bash

# https://github.com/pyenv/pyenv

if !(type "pyenv" > /dev/null 2>&1); then
 git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
 cd ~/.pyenv && src/configure && make -C src
 if ! [ -e $HOME/.pyenv/plugins/pyenv-virtualenv ]; then
   if ! [ -d $HOME/.pyenv/plugins ]; then
     mkdir $HOME/.pyenv/plugins
   fi
   git clone https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
 fi
fi

PYTHON2_VERSION="2.7.18"
PYTHON3_VERSION="3.8.3"
echo "-----------------↓copy and run--------------------"

echo pyenv install $PYTHON2_VERSION;

echo pyenv install $PYTHON3_VERSION;

echo pyenv virtualenv $PYTHON2_VERSION neovim2;

echo pyenv activate neovim2;

echo pip2 install pynvim;

echo pyenv virtualenv $PYTHON3_VERSION neovim3;

echo pyenv activate neovim3;

echo pip install pynvim;
echo "-----------------↑copy and run--------------------"
