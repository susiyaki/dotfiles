local utils = require('utils')

vim.g.mapleader = ' '

utils.map('n', 'j', 'gj', { noremap = true, silent = true })
utils.map('n', 'k', 'gk', { noremap = true, silent = true })
utils.map('n', '<down>', 'gj', { noremap = true, silent = true })
utils.map('n', '<up>', 'gk', { noremap = true, silent = true })
utils.map('n', '_', ':-', { noremap = true, silent = false })
utils.map('n', '+', ':+', { noremap = true, silent = false })


utils.map('n', 's', '<Nop>')
utils.map('n', 'ss', ':<C-u>sp<CR>', { noremap = true, silent = true })
utils.map('n', 'sv', ':<C-u>vs<CR>', { noremap = true, silent = true })
utils.map('n', 'sj', '<C-w>j', { noremap = true, silent = true })
utils.map('n', 'sk', '<C-w>k', { noremap = true, silent = true })
utils.map('n', 'sl', '<C-w>l', { noremap = true, silent = true })
utils.map('n', 'sh', '<C-w>h', { noremap = true, silent = true })
utils.map('n', 'sJ', '<C-w>J', { noremap = true, silent = true })
utils.map('n', 'sK', '<C-w>K', { noremap = true, silent = true })
utils.map('n', 'sL', '<C-w>L', { noremap = true, silent = true })
utils.map('n', 'sH', '<C-w>H', { noremap = true, silent = true })
utils.map('n', '<C-Right>', 'gt', { noremap = true, silent = true })
utils.map('n', '<C-Left>', 'gT', { noremap = true, silent = true })
utils.map('n', 'st', ':<C-u>tabnew<CR>', { noremap = true, silent = true })
utils.map('n', '<ESC><ESC>', ':<C-u>set nohlsearch!<CR>', { noremap = true, silent = true })

utils.map('n', '<Leader>w', ':w<CR>')
utils.map('n', '<Leader>q', ':q!<CR>')
utils.map('n', '<Leader>ee', ':e!<CR>', { noremap = true, silent = true })
utils.map('n', '<Leader>pmd', '<CMD>lua require("utils").markdown_preview()<CR>', { noremap = true, silent = true })

utils.map('n', 'q', 'qq<ESC>')
utils.map('n', '@', "reg_recording() == '' ? '@q' : ''", { expr = true })

utils.map('n', '<C-c>', '<Nop>')

-- defxと競合しているkeymapを削除
vim.api.nvim_del_keymap('n', '<C-w><C-d>')
vim.api.nvim_del_keymap('n', '<C-w>d')

utils.map('i', 'jj', '<ESC>')
utils.map('t', '<ESC>', '<C-\\><C-n>')

-- utils.map('n', ']r', ':luafile ~/.config/nvim/lua/plugins/lsp/mason_lspconfig.lua<CR>', { noremap = true, silent = true })

vim.cmd([[
  au FileType qf nnoremap <silent><buffer>q :quit<CR>
]])
