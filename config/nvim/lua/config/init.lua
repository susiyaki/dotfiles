require('config.settings')
require('config.filetype')

-- AI Assistant の初期化
if not vim.env.NVIM_INSTANCE_ID then
  vim.env.NVIM_INSTANCE_ID = tostring(vim.fn.getpid())
end

-- AI_ASSISTANT is required (set via home-manager)

-- バックグラウンドで AI Assistant セッションを事前起動
vim.defer_fn(function()
  -- tmux 内でのみ実行
  if vim.env.TMUX then
    local assistant = vim.env.AI_ASSISTANT
    if not assistant or assistant == "" then
      -- AI_ASSISTANT が設定されていない場合はバックグラウンド起動をスキップ
      return
    end

    local instance_id = vim.env.NVIM_INSTANCE_ID or vim.fn.getpid()
    local session_name = string.format("ai-%s-%s", assistant, instance_id)
    local cwd = vim.fn.getcwd()

    -- セッションが既に存在するかチェック
    local check_cmd = string.format("tmux has-session -t %s 2>/dev/null",
      vim.fn.shellescape(session_name))
    vim.fn.system(check_cmd)

    -- セッションが存在しない場合のみ作成
    if vim.v.shell_error ~= 0 then
      local assistant_cmd = assistant == "claude" and "claude code" or "gemini-cli"
      local create_cmd = string.format(
        "tmux new-session -d -s %s -c %s -e NVIM_INSTANCE_ID=%s -e AI_ASSISTANT=%s '%s' 2>/dev/null",
        vim.fn.shellescape(session_name),
        vim.fn.shellescape(cwd),
        instance_id,
        assistant,
        assistant_cmd
      )
      vim.fn.jobstart(create_cmd)
    end
  end
end, 500) -- 500ms 後に実行（起動の邪魔にならないように）
