#!/bin/bash

# https://github.com/cehoffman/luaenv
# https://github.com/cehoffman/lua-build#readme
# https://github.com/xpol/luaenv-luarocks
if !(type "luaenv" > /dev/null 2>%1); then
  git clone https://github.com/cehoffman/luaenv.git ~/.luaenv
  $HOME/.luaenv/bin/luaenv init
  if ! [ -d $OME/.luaenv/plugins ]; then
    mkdir $HOME/.luaenv/plugins
  fi
  git clone git://github.com/cehoffman/lua-build.git ~/.luaenv/plugins/lua-build
  git clone https://github.com/xpol/luaenv-luarocks.git ~/.luaenv/plugins/luaenv-luarocks
  echo "luaenv was installed. Should relogin shell."
  # TODO; インストールできないことあるからバージョン固定
  echo "Should run following:"
  echo "  luaenv install 5.1.5"
  echo "  luaenv luarocks 2.4.3"
fi
