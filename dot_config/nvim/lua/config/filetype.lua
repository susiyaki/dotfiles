vim.cmd([[
  autocmd vimrc BufRead,BufNewFile *.tag set filetype=javascript
  autocmd vimrc BufRead,BufNewFile *.ts set filetype=typescript
  autocmd vimrc BufRead,BufNewFile *.jsx set filetype=javascriptreact
  autocmd vimrc BufRead,BufNewFile *.tsx set filetype=typescriptreact
  autocmd vimrc BufRead,BufNewFile *.md set filetype=markdown
  autocmd vimrc BufRead,BufNewFile *.dart set filetype=dart
  autocmd vimrc BufRead,BufNewFile *.ex,*.exs set filetype=elixir
  autocmd vimrc BufRead,BufNewFile *.eex set filetype=eelixir
  autocmd vimrc BufRead,BufNewFile *.kt set filetype=kotlin
  autocmd vimrc BufRead,BufNewFile *.bash set filetype=bash
  autocmd vimrc BufRead,BufNewFile *.zsh set filetype=zsh
  autocmd vimrc BufRead,BufNewFile *.lua set filetype=lua
  autocmd vimrc BufRead,BufNewFile *.toml set filetype=toml
]])
