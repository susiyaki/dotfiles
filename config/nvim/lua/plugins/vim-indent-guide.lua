vim.g.indent_guides_enable_on_vim_startup = 1
vim.g.indent_guides_exclude_filetypes = {'defx'}
vim.g.indent_guides_start_level = 2
vim.g.indent_guides_guide_size = 1
vim.g.indent_guides_auto_colors = 0

vim.cmd([[
autocmd vimrc VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=0
autocmd vimrc VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=8
]])
