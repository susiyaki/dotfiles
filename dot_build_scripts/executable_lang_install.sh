#!/bin/bash

declare -A apps=(
["nodenv"]="nodenv install -l"
["rbenv"]="rbenv install -l"
["luaenv"]="luaenv install -l"
["pyenv"]="pyenv install -l"
["dvm"]="dvm listall"
["fvm"]="fvm releases | awk "{print $5}"'
)

declare -A install_commands=(
  ["nodenv"]='nodenv install version'
  ["rbenv"]='rbenv install version'
  ["luaenv"]='luaenv install version'
  ["pyenv"]='pyenv install version'
  ["dvm"]='dvm install version'
  ["fvm"]='fvm install version'
)

echo "Select following command:"

for app in ${!apps[@]}; do
  if (type $app > /dev/null 2>&1); then
    echo "  - $app"
  fi
done

read -p ">> " app


version=$(${apps[$app]} | fzf --reverse --preview-window="hidden" | sed "s/ //g")

echo "Start install:"
echo "  cmd    : $app"
echo "  version: $version"

$(echo ${install_commands[$app]} | sed "s/version/$version/")
