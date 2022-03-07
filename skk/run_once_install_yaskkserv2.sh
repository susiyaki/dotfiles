#!/bin/sh

SKK_CONFIG_DIR=$PWD
JISYO_FILENAME=dictionary.yaskkserv2
CACHE_FILENAME=yaskkserv2.cache
JISYO_SOURCE_LIST=$SKK_CONFIG_DIR/jisyo.txt
declare -a jisyoSources
jisyoSources=(`cat "$JISYO_SOURCE_LIST"`)

function main() {
  echo "Start to setup yaskkserv2."

  # Build yaskkserv2
  cd $HOME/git/yaskkserv2
  echo "Building yaskkserv2..."
  echo ""
  cargo build --release

  echo ""
  echo ""
  echo "Build is completed."

  echo ""
  sudo cp -av target/release/yaskkserv2 /usr/local/bin
  echo "Copied yaskkserv2 to /usr/local/bin."
  sudo cp -av target/release/yaskkserv2_make_dictionary /usr/local/bin
  echo "Copied yaskkserv2_make_dictionary to /usr/local/bin."
  echo ""

  echo "Generating dictionary file for yaskkserv2."
  cd $HOME/git/dict
  yaskkserv2_make_dictionary --dictionary-filename=$SKK_CONFIG_DIR/$JISYO_FILENAME ${jisyoSources[@]} ../skk-jisyo-neologd/SKK-JISYO.neologd &>/dev/null

  echo "Finished to setup yaskkserv2."
}
