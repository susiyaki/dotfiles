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
  local assistant = vim.env.AI_ASSISTANT or "claude"
  vim.fn.system(string.format("tmux set-option -wq @ai_assistant %s", assistant))
  vim.fn.system("tmux refresh-client -S")

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      vim.fn.system("tmux set-option -p @nvim_instance_id ''")
      local window_id = vim.fn.system("tmux display-message -p '#{window_id}'"):gsub("%s+$", "")
      if window_id ~= "" then
        local cleanup_script = vim.fn.expand("~/.config/tmux/scripts/ai-pane-cleanup.sh")
        vim.fn.jobstart({cleanup_script, window_id})
      end
      vim.fn.system("tmux refresh-client -S")
    end,
  })
end
