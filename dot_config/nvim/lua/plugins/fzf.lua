vim.g.fzf_action = {
  ['ctrl-o'] = 'vs',
  ['ctrl-t'] = 'tabnew'
}

vim.cmd([[
command! -bang -nargs=* Rg call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.<q-args>, 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4.. --no-sort'}, 'right:50%', '?'), <bang>0)
]])
