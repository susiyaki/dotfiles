#!/bin/sh

SKK_CONFIG_DIR=$HOME/skk
SKK_GIT_REPO=$HOME/skk/git

JISYO_FILENAME=dictionary.yaskkserv2

declare -a jisyoSources
jisyoSources=(`cat "$SKK_CONFIG_DIR/jisyo.txt"`)

function main() {
  echo "Start to setup yaskkserv2."

  # Build yaskkserv2
  cd $SKK_GIT_REPO/yaskkserv2
  echo "Building yaskkserv2..."
  echo ""
  cargo build --release

  echo ""
  echo ""

  if [ ! -f /usr/local/bin/yaskkserv2 ]; then
    echo ""
    sudo cp -av target/release/yaskkserv2 /usr/local/bin
    echo "Copied yaskkserv2 to /usr/local/bin."
    echo ""
  fi

  if [ ! -f /usr/local/bin/yaskkserv2_make_dictionary ]; then
    echo ""
    sudo cp -av target/release/yaskkserv2_make_dictionary /usr/local/bin
    echo "Copied yaskkserv2_make_dictionary to /usr/local/bin."
    echo ""
  fi

  echo "Generating dictionary file for yaskkserv2..."
  cd $SKK_GIT_REPO/dict
  yaskkserv2_make_dictionary --dictionary-filename=$SKK_CONFIG_DIR/$JISYO_FILENAME ${jisyoSources[@]} $SKK_GIT_REPO/skk-jisyo-neologd/SKK-JISYO.neologd &>/dev/null
  echo "Done."

  echo "Finished to setup yaskkserv2."
  echo ""
}

main
