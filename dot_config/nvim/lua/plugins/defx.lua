vim.fn['defx#custom#option']('_', {
  winwidth = 35,
  split = 'vertical',
  direction = 'topleft',
  toggle = 1,
  resume = 1,
  columns = 'indent:git:icons:filename:mark'
})

vim.cmd([[
function! Defx_my_settings() abort
  nnoremap <silent><buffer><expr> <CR> defx#is_directory() ? defx#do_action('open_tree', 'toggle') : defx#do_action('drop')
  nnoremap <silent><buffer><expr> o defx#do_action('open')
  nnoremap <silent><buffer><expr> t defx#do_action('open', 'tabnew')

  nnoremap <silent><buffer><expr> E defx#do_action('open', 'vsplit')

  nnoremap <silent><buffer><expr> c defx#do_action('copy')

  nnoremap <silent><buffer><expr> m defx#do_action('move')

  nnoremap <silent><buffer><expr> p defx#do_action('paste')

  nnoremap <silent><buffer><expr> K defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N defx#do_action('new_file')
  nnoremap <silent><buffer><expr> M defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> d defx#do_action('remove')
  nnoremap <silent><buffer><expr> r defx#do_action('rename')
  nnoremap <silent><buffer><expr> <Tab> defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> * defx#do_action('toggle_select_all')

  nnoremap <silent><buffer><expr> yy defx#do_action('yank_path')

  nnoremap <silent><buffer><expr> . defx#do_action('toggle_ignored_files')

  nnoremap <silent><buffer><expr> ; defx#do_action('repeat')

  nnoremap <silent><buffer><expr> h defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> ~ defx#do_action('cd')
  nnoremap <silent><buffer><expr> cd defx#do_action('change_vim_cwd')

  nnoremap <silent><buffer><expr> q defx#do_action('quit')

  nnoremap <silent><buffer><expr> j line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k line('.') == 1 ? 'G' : 'k'
endfunction

autocmd vimrc BufWritePost * call defx#redraw()
autocmd vimrc BufEnter * call defx#redraw()
autocmd FileType defx call Defx_my_settings()
]])
