local fn = vim.fn
local execute = vim.api.nvim_command

vim.cmd([[
augroup vimrc
  autocmd!
augroup END
]])

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end
vim.cmd [[packadd packer.nvim]]
vim.cmd 'autocmd vimrc BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua

require('config')
require('keys')
require('plugin')