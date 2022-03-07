#!/bin/bash

SKK_CONFIG_DIR=$HOME/skk
JISYO_FILENAME=dictionary.yaskkserv2
CACHE_FILENAME=yaskkserv2.cache
JISYO_SOURCE_LIST=$PWD/jisyo.txt
declare -a jisyoSources
jisyoSources=(`cat "$JISYO_SOURCE_LIST"`)

# Make git directory
if ! [[ -d $HOME/git ]]; then
  mkdir $HOME/git
fi

# Clone and build yaskkserv2
if ! [[ -d $HOME/git/yaskkserv2 ]]; then
  git clone https://github.com/wachikun/yaskkserv2.git $HOME/git/yaskkserv2
  cd $HOME/git/yaskkserv2
  cargo build --release

  sudo cp -av target/release/yaskkserv2 /usr/local/bin
  sudo cp -av target/release/yaskkserv2_make_dictionary /usr/local/bin
fi

# Clone base dictionary
if ! [[ -d $HOME/git/dict ]]; then
  git clone git@github.com:skk-dev/dict.git $HOME/git/dict
fi

# Clone utility dictionary
if ! [[ -d $HOME/git/skk-jisyo-neologd ]]; then
  git clone git@github.com:tokuhirom/skk-jisyo-neologd.git $HOME/git/skk-jisyo-neologd
fi

# Make skk config
if ! [[ -d $SKK_CONFIG_DIR ]]; then
  mkdir $SKK_CONFIG_DIR
fi

# Generate JISYO file
cd $HOME/git/dict
yaskkserv2_make_dictionary --dictionary-filename=$SKK_CONFIG_DIR/$JISYO_FILENAME ${jisyoSources[@]} ../skk-jisyo-neologd/SKK-JISYO.neologd

# Test run
yaskkserv2 --no-daemonize --google-japanese-input=notfound --google-suggest --google-cache-filename=$SKK_CONFIG_DIR/$CACHE_FILENAME $SKK_CONFIG_DIR/$JISYO_FILENAME
