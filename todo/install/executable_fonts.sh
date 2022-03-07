#!/bin/bash

git clone git@github.com:ryanoasis/nerd-fonts.git $HOME/nerd-fonts

sh -c "$HOME/nerd-fonts/install.sh"

rm -rf $HOME/nerd-fonts
