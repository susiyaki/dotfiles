require('config.settings')
require('config.filetype')

-- AI Assistant の初期化
if not vim.env.NVIM_INSTANCE_ID then
  vim.env.NVIM_INSTANCE_ID = tostring(vim.fn.getpid())
end

-- tmux 内であれば、pane に NVIM_INSTANCE_ID を設定
-- これにより C-q C-[ または [[ で現在の pane の Neovim に紐づいた AI ペインを開ける
if vim.env.TMUX then
  local instance_id = vim.env.NVIM_INSTANCE_ID
  vim.fn.system(string.format("tmux set-option -p @nvim_instance_id %s", instance_id))
end
