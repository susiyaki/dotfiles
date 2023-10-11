local utils = require('utils')

utils.map('i', '<C-j>', '<Plug>(skkeleton-enable)', { noremap = false })
utils.map('i', 'jk', '<Plug>(skkeleton-enable)', { noremap = false })
-- 子音があると1文字目だけうまく動かないので、1回打って消して回避している
utils.map('c', '<C-j>', '<Plug>(skkeleton-enable)ka<DEL>', { noremap = false, silent = true })
utils.map('c', 'jk', '<Plug>(skkeleton-enable)ka<DEL>', { noremap = false, silent = true })

utils.map('i', 'jj', '<ESC>')


vim.cmd([[
function! s:skkeleton_init() abort
  call skkeleton#config({
    \ 'debug': v:false,
    \ 'eggLikeNewline': v:true,
    \ 'globalJisyo': '~/skk/SKK-JISYO.L',
    \ 'userJisyo': '~/.skkeleton',
    \ 'useSkkServer': v:false,
    \ 'showCandidatesCount': 2
    \ })
  call skkeleton#register_kanatable('rom', {
    \ 'jj': 'escape',
    \ 'z\/': '・',
    \ "z\<Space>": ["\u3000", ''],
    \ })
endfunction
augroup skkeleton-initialize-pre
  autocmd!
  autocmd User skkeleton-initialize-pre call s:skkeleton_init()
augroup END
]])
