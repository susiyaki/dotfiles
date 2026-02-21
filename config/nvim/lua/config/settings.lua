local api = vim.api

local vars = {
  -- python3_host_prog is now managed by Nix (programs.neovim.withPython3)
  loaded_matchparen = 1
}

-- Load Nix-managed host programs if they exist
pcall(require, 'nix-hosts')

for var, val in pairs(vars) do
  api.nvim_set_var(var, val)
end

local utils = require('utils')

local cmd = vim.cmd
local indent = 2

cmd [[
  set termguicolors
  syntax enable
  filetype plugin indent on
  set noswapfile
  set nobackup
  set fileencodings=utf-8
]]
utils.opt('o', 'encoding', 'utf-8')
utils.opt('b', 'autoread', true)
utils.opt('b', 'expandtab', true)
utils.opt('b', 'shiftwidth', indent)
utils.opt('b', 'smartindent', true)
utils.opt('b', 'tabstop', indent)
utils.opt('o', 'hidden', true)
utils.opt('o', 'ignorecase', true)
utils.opt('o', 'scrolloff', 4 )
utils.opt('o', 'shiftround', true)
utils.opt('o', 'smartcase', true)
utils.opt('o', 'splitbelow', true)
utils.opt('o', 'splitright', true)
utils.opt('o', 'wildmode', 'list:longest')
utils.opt('w', 'number', true)
utils.opt('w', 'relativenumber', true)
utils.opt('o', 'clipboard','unnamed,unnamedplus')
utils.opt('o', 'whichwrap', 'b,s,h,l,<,>,[,],~')
utils.opt('o', 'completeopt', 'menuone,noinsert')

-- Highlight on yank
vim.cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'

-- fmt
vim.g.shfmt_opt = "-ci"
