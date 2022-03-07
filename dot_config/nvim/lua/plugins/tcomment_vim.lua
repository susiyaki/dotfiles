vim.g.tcomment_types = {
  ['eruby_surrond'] = '<%%# %s %%>',
}

vim.cmd([[
function! SetErubyMapping2()
  nmap <buffer> sc :TCommentAs eruby_surround_minus<CR>
endfunction

" erubyのときだけ設定を追加
au FileType eruby call SetErubyMapping2()
]])
