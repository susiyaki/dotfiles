local utils = require('utils')

vim.cmd([[
  let g:quickrun_config = {}

  let g:quickrun_config._ = {
      \ 'runner'                          : 'vimproc',
      \ 'runner/vimproc/updatetime'       : 60,
      \ 'hook/time/enable'                : 1,
      \ 'hook/time/format'                : "\n*** time : %g s ***",
      \ 'hook/time/dest'                  : '',
      \ 'outputter'                       : 'error',
      \ 'outputter/error/success'         : 'buffer',
      \ 'outputter/error/error'           : 'quickfix',
      \ 'outputter/buffer/split'          : ':rightbelow 8sp',
      \ 'outputter/buffer/close_on_empty' : 1,
  \}
]])

utils.map('n', 'gr', ':cclose<CR>:QuickRun -mode n<CR>', { noremap = false })
utils.map('x', 'gr', ':<C-U>cclose<CR>gv:QuickRun -mode v<CR>', { noremap = false })

utils.map('n', '<C-c>', "quickrun#is_running() ? quickrun#sweep_sessions() : '<C-c>'", { noremap = false, expr = true, silent = true })



