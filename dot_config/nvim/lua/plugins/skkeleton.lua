local utils = require('utils')

utils.map('i', 'jk', '<Plug>(skkeleton-enable)', { noremap = false })
utils.map('c', 'jk', '<Plug>(skkeleton-disalbed)', { noremap = false })
utils.map('i', 'jj', '<ESC>')

vim.cmd([[
function! s:skkeleton_init() abort
  call skkeleton#config({
    \ 'debug': v:false,
    \ 'eggLikeNewline': v:true,
    \ 'userDictionary': '~/.skkeleton',
    \ 'globalDictionaries': ['~/skk/SKK-JISYO.L'],
    \ 'showCandidatesCount': 2,
    \ 'sources': ['skk_dictionary', 'google_japanese_input'],
    \ })
  call skkeleton#register_kanatable('rom', {
    \ 'jj': 'escape',
    \ "z\<Space>": ["\u3000", ''],
    \ })
endfunction

augroup skkeleton-initialize-pre
  autocmd!
  autocmd User skkeleton-initialize-pre call s:skkeleton_init()
augroup END
]])

