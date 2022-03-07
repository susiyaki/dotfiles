-- https://github.com/sbdchd/neoformat

local utils = require('utils')

-- debug
-- vim.g.neoformat_verbose = 1

utils.map('n', '<Leader>f', "<Cmd>Neoformat<CR>")

-- stylesheet
vim.g.neoformat_enabled_css = { 'prettier' }

vim.g.neoformat_enabled_less = { 'prettier' }

vim.g.neoformat_enabled_scss = { 'prettier' }

vim.g.neoformat_enabled_sass = { 'prettier' }

-- javascript typescript
vim.g.neoformat_enabled_javascript = { 'prettier' }
vim.g.neoformat_enabled_typescript = { 'prettier' }

-- dart
vim.g.neoformat_enabled_dart = { 'dartfmt' }

-- zsh
vim.g.neoformat_enabled_zsh = { 'shfmt' }

-- sql
vim.g.neoformat_enabled_sql = { 'sqlfmt' }

-- rust
vim.g.neoformat_enabled_rust = { 'rustfmt' }

-- yaml xml
vim.g.neoformat_enabled_yaml = { 'prettier' }
vim.g.neoformat_enabled_xml = { 'prettier' }
