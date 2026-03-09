-- AI Assistant integration for tmux pane
-- No plugin dependency required

-- AI pane を探す (pane option を使用)
local function get_ai_pane_id(pane_marker)
  -- 末尾に一致するように grep を調整
  local cmd = string.format("tmux list-panes -F '#{pane_id} #{@ai_pane_marker}' | grep ' %s$' | cut -d' ' -f1", pane_marker)
  local pane_id = vim.fn.system(cmd):gsub("%s+$", "")
  return pane_id ~= "" and pane_id or nil
end

-- AI Assistant へプロンプトを送信する関数
-- floating と popup を常にセットで開く
local function prompt_and_send_to_ai()
  local assistant = vim.env.AI_ASSISTANT
  if not assistant or assistant == "" then
    vim.notify("AI_ASSISTANT environment variable is not set.", vim.log.levels.ERROR)
    return
  end

  local instance_id = vim.env.NVIM_INSTANCE_ID or vim.fn.getpid()
  local window_id = vim.fn.system("tmux display-message -p '#{window_id}'"):gsub("%s+$", "")
  if window_id == "" then
    window_id = tostring(instance_id)
  end
  local pane_marker = string.format("ai_pane_%s_%s", window_id, assistant)

  local config = {
    assistant = assistant,
    instance_id = instance_id,
    window_id = window_id,
    pane_marker = pane_marker,
  }

  -- フローティングウィンドウの設定
  local ui = vim.api.nvim_list_uis()[1]
  local win_width = ui.width
  local win_height = ui.height

  -- 画面幅の98%を使用（tmux popup と揃える）
  local width = math.floor(win_width * 0.98)
  local height = 13
  local buf = vim.api.nvim_create_buf(false, true)

  local col = math.floor((win_width - width) / 2)  -- 横は中央
  -- Keep clear of statusline/cmdline/tabline so file name isn't covered.
  local statusline = (vim.o.laststatus and vim.o.laststatus > 0) and 1 or 0
  local cmdline = vim.o.cmdheight or 0
  local tabline = (vim.o.showtabline and vim.o.showtabline > 0) and 1 or 0
  local reserved = statusline + cmdline + tabline + 1
  local row = win_height - height - reserved

  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = string.format(' %s [%s] (Ctrl+k: 送信) ',
      config.assistant:upper(),
      config.instance_id),
    title_pos = 'center',
  }
  local win = vim.api.nvim_open_win(buf, true, opts)

  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

  local function send_input()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local input = table.concat(lines, '\n')

    if input and input ~= '' then
      -- clipboard に保存
      vim.fn.setreg('+', input, 'c')

      -- AI pane を探す
      local ai_pane_id = get_ai_pane_id(config.pane_marker)
      if not ai_pane_id then
        vim.notify("AI pane not found. Please open it first with ,,", vim.log.levels.WARN)
        return
      end

      -- tmux の AI pane にプロンプトを送信 + Enter を自動実行
      local send_cmd = string.format("tmux send-keys -t %s %s Enter",
        vim.fn.shellescape(ai_pane_id),
        vim.fn.shellescape(input))

      vim.fn.jobstart(send_cmd)

      -- AI pane にフォーカスを移動
      local focus_cmd = string.format("tmux select-pane -t %s", vim.fn.shellescape(ai_pane_id))
      vim.fn.jobstart(focus_cmd)
    end

    -- floating を閉じる
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- キーマップ設定
  vim.keymap.set({'n', 'i'}, '<C-k>', function()
    if vim.api.nvim_get_mode().mode == 'i' then
      vim.cmd('stopinsert')
    end
    vim.schedule(send_input)
  end, { buffer = buf, noremap = true, silent = true })

  vim.cmd('startinsert')

  -- floating 表示後、ペインで AI を開く
  vim.defer_fn(function()
    local script_path = vim.fn.expand("~/.config/tmux/scripts/ai-pane-toggle.sh")
    vim.fn.jobstart(script_path, {
      env = {
        AI_ASSISTANT = config.assistant,
        AI_ARGS = vim.env.AI_ARGS or "",
        NVIM_INSTANCE_ID = tostring(config.instance_id),
        NVIM_CWD = vim.fn.getcwd(),
        AI_ACTION = "open",
      },
    })
  end, 100)
end

-- AI Assistant の引数を切り替える関数
local function switch_ai_args()
  local assistant = vim.env.AI_ASSISTANT or "claude"
  local args_presets = {
    claude = {"", "--fast", "--debug", "--dangerously-skip-permissions"},
    gemini = {"", "--thinking", "--debug"},
    codex = {"", "--debug"},
  }
  local current_args = vim.env.AI_ARGS or ""
  local options = args_presets[assistant] or {""}

  vim.ui.select(options, {
    prompt = string.format("Select arguments for %s:", assistant:upper()),
    format_item = function(item)
      if item == "" then return "(none)" end
      return item == current_args and item .. " (current)" or item
    end,
  }, function(choice)
    if choice ~= nil then
      vim.env.AI_ARGS = choice
      vim.notify(string.format("AI Args for %s set to: %s", assistant:upper(), choice == "" and "(none)" or choice), vim.log.levels.INFO)
    end
  end)
end

-- AI Assistant の切り替え関数
local function switch_ai_assistant()
  local assistants = {"claude", "gemini", "codex"}
  local current = vim.env.AI_ASSISTANT or "claude"

  vim.ui.select(assistants, {
    prompt = "Select AI Assistant:",
    format_item = function(item)
      return item == current and item .. " (current)" or item
    end,
  }, function(choice)
    if choice then
      vim.env.AI_ASSISTANT = choice
      if vim.env.TMUX then
        vim.fn.jobstart({"tmux", "set-environment", "AI_ASSISTANT", choice})
        vim.fn.jobstart({"tmux", "set-option", "-wq", "@ai_assistant", choice})
        vim.fn.jobstart({"tmux", "refresh-client", "-S"})
      end
      -- アシスタントを切り替えたら引数をリセット
      vim.env.AI_ARGS = ""
      vim.notify(string.format("AI Assistant switched to: %s", choice:upper()), vim.log.levels.INFO)
    end
  end)
end

-- キーマッピングを設定
-- ノーマルモード: ,, でプロンプト入力
vim.keymap.set('n', ',,', prompt_and_send_to_ai,
  { noremap = true, silent = false, desc = 'Send prompt to AI Assistant (tmux pane)' })

-- ターミナルモード: ,, でプロンプト入力
vim.keymap.set('t', ',,', function()
  vim.cmd('stopinsert')
  vim.schedule(prompt_and_send_to_ai)
end, { noremap = true, silent = false, desc = 'Send prompt to AI Assistant from terminal mode' })

-- AI Assistant 切り替え: <Space>,,
vim.keymap.set('n', '<Space>,,', switch_ai_assistant,
  { noremap = true, silent = false, desc = 'Switch AI Assistant' })

-- AI Assistant 引数切り替え: <Space>,<Space>
vim.keymap.set('n', '<Space>, ', switch_ai_args,
  { noremap = true, silent = false, desc = 'Switch AI Assistant Arguments' })
