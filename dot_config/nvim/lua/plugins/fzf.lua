local utils = require('utils')
-- grep

utils.map('n', '<C-]><C-g>', ':GFiles<CR>', { noremap = true, silent = true })
utils.map('n', '<C-]><C-f>', ':Files<CR>', { noremap = true, silent = true })
utils.map('n', '<C-]><C-b>', ':Buffers<CR>', { noremap = true, silent = true })
utils.map('n', '<C-g><C-g>', ':Rg<Space>', { noremap = true, silent = true })
utils.map('n', '<C-g><C-w>', ':Rg <C-R><C-w><CR>', { noremap = true, silent = true })

utils.map('n', '<C-]>s', ':GFiles?<CR>', { noremap = true, silent = true })
utils.map('n', '<C-]>c', ':Commits<CR>', { noremap = true, silent = true })
utils.map('n', '<C-]>bc', ':BCommits<CR>', { noremap = true, silent = true })

utils.map('n', '<C-]><C-c>', ':History:<CR>', { noremap = true, silent = true })
utils.map('n', '<C-]><C-s>', ':History/<CR>', { noremap = true, silent = true })
utils.map('n', '<Leader><Leader>', ':Commands<CR>', { noremap = true, silent = true })

vim.g.fzf_action = {
  ['ctrl-o'] = 'vs',
  ['ctrl-t'] = 'tabnew'
}

vim.cmd([[
command! -bang -nargs=* Rg call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.<q-args>, 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4.. --no-sort'}, 'right:50%', '?'), <bang>0)
]])
