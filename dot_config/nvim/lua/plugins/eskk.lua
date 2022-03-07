local utils = require('utils')

vim.g["eskk#directory"] = "~/.eskk"
vim.g["eskk#dictionary"] = {
  ['path'] = "~/.eskk-jisyo",
  ['sorted'] = 0,
  ['encoding'] = 'utf-8'
}
vim.g["eskk#large_dictionary"] = {
  ['path'] = "~/.config/SKK-JISYO.L",
  ['sorted'] = 1,
  ['encoding'] = 'utf-8'
}
vim.g["eskk#server"] = {
  ['host'] = 'localhost',
  ['port'] = 1178
}

vim.g["eskk#kakutei_when_unique_candidate"] = 1 -- "漢字変換した時に候補が1つの場合、自動的に確定する
vim.g["eskk#enable_completion"] = 0
vim.g["eskk#no_default_mappings"] = 1
vim.g["eskk#keep_state"] = 0
vim.g["eskk#egg_like_newline"] = 1
vim.g["eskk#tab_select_completion"] = 1


vim.cmd([[
augroup vimrc_eskk
  autocmd!
  autocmd User eskk-enable-post lmap <buffer> l <Plug>(eskk:disable)
augroup END
]])

utils.map('i', 'jk', '<Plug>(eskk:toggle)', { noremap = false })
utils.map('c', 'jk', '<Plug>(eskk:toggle)', { noremap = false })
