-- AI Assistant integration for tmux popup
-- No plugin dependency required

-- AI Assistant の設定取得
local function get_ai_config()
  local assistant = vim.env.AI_ASSISTANT
  if not assistant or assistant == "" then
    vim.notify("AI_ASSISTANT environment variable is not set. Please set it in your shell or home-manager config.", vim.log.levels.ERROR)
    error("AI_ASSISTANT not set")
  end

  local instance_id = vim.env.NVIM_INSTANCE_ID or vim.fn.getpid()
  local session_name = string.format("ai-%s-%s", assistant, instance_id)

  return {
    assistant = assistant,
    instance_id = instance_id,
    session_name = session_name,
    target_pane = session_name .. ":"
  }
end

-- AI Assistant へプロンプトを送信する関数
local function prompt_and_send_to_ai()
  local config = get_ai_config()

  -- フローティングウィンドウの設定
  local width = 80
  local height = 5
  local buf = vim.api.nvim_create_buf(false, true)

  local ui = vim.api.nvim_list_uis()[1]
  local win_width = ui.width
  local win_height = ui.height
  local col = math.floor((win_width - width) / 2)
  local row = math.floor((win_height - height) / 2)

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

    vim.api.nvim_win_close(win, true)

    if input and input ~= '' then
      -- clipboard に保存
      vim.fn.setreg('+', input, 'c')

      -- tmux セッションの存在確認
      local check_cmd = string.format("tmux has-session -t %s 2>/dev/null",
        vim.fn.shellescape(config.session_name))
      vim.fn.system(check_cmd)

      local session_exists = vim.v.shell_error == 0

      -- tmux にプロンプトを送信（Enter は押さない）
      local send_cmd = string.format("tmux send-keys -t %s %s",
        vim.fn.shellescape(config.target_pane),
        vim.fn.shellescape(input))

      vim.fn.jobstart(send_cmd, {
        on_exit = function(_, exit_code)
          if exit_code == 0 then
            vim.notify(string.format("Sent to %s [%s]",
              config.assistant:upper(),
              config.instance_id),
              vim.log.levels.INFO)

            -- 送信成功後、tmux popup を自動的に開く
            local script_path = vim.fn.expand("~/.config/tmux/scripts/ai-popup.sh")
            vim.fn.jobstart(script_path, {
              env = {
                AI_ASSISTANT = config.assistant,
                NVIM_INSTANCE_ID = tostring(config.instance_id),
                NVIM_CWD = vim.fn.getcwd(),
              },
              on_stderr = function(_, data, _)
                if data and #data > 0 then
                  local err = table.concat(data, "\n")
                  if err ~= "" then
                    vim.notify("AI popup error: " .. err, vim.log.levels.ERROR)
                  end
                end
              end,
              on_exit = function(_, code, _)
                if code ~= 0 then
                  vim.notify(string.format("AI popup script failed (exit code: %d). Check /tmp/ai-popup-error.log", code), vim.log.levels.ERROR)
                end
              end,
            })
          else
            if not session_exists then
              vim.notify(string.format(
                "%s session not found. Creating new session...",
                config.assistant:upper()),
                vim.log.levels.WARN)

              -- セッションを作成して popup を開く
              local script_path = vim.fn.expand("~/.config/tmux/scripts/ai-popup.sh")
              vim.fn.jobstart(script_path, {
                env = {
                  AI_ASSISTANT = config.assistant,
                  NVIM_INSTANCE_ID = tostring(config.instance_id),
                  NVIM_CWD = vim.fn.getcwd(),
                },
                on_stderr = function(_, data, _)
                  if data and #data > 0 then
                    local err = table.concat(data, "\n")
                    if err ~= "" then
                      vim.notify("AI popup error: " .. err, vim.log.levels.ERROR)
                    end
                  end
                end,
                on_exit = function(_, code, _)
                  if code ~= 0 then
                    vim.notify(string.format("AI popup script failed (exit code: %d). Check /tmp/ai-popup-error.log", code), vim.log.levels.ERROR)
                  end
                end,
              })
            else
              vim.notify("Failed to send to tmux", vim.log.levels.ERROR)
            end
          end
        end
      })
    end
  end

  local function cancel_input()
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

  vim.keymap.set({'n', 'i'}, '<Esc>', function()
    if vim.api.nvim_get_mode().mode == 'i' then
      vim.cmd('stopinsert')
    end
    vim.schedule(cancel_input)
  end, { buffer = buf, noremap = true, silent = true })

  vim.cmd('startinsert')
end

-- AI Assistant の切り替え関数
local function switch_ai_assistant()
  local assistants = {"claude", "gemini"}
  local current = vim.env.AI_ASSISTANT or "claude"

  vim.ui.select(assistants, {
    prompt = "Select AI Assistant:",
    format_item = function(item)
      return item == current and item .. " (current)" or item
    end,
  }, function(choice)
    if choice then
      vim.env.AI_ASSISTANT = choice
      vim.notify(string.format("AI Assistant switched to: %s", choice:upper()), vim.log.levels.INFO)
    end
  end)
end

-- ビジュアルモード選択テキストを送信する関数
local function send_selection_to_ai()
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg('v')
  vim.cmd("normal! gvd")

  local config = get_ai_config()

  -- clipboard に保存
  vim.fn.setreg('+', selected_text, 'c')

  -- tmux に送信
  local cmd = string.format("tmux send-keys -t %s %s",
    vim.fn.shellescape(config.target_pane),
    vim.fn.shellescape(selected_text))

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify(string.format("Selection sent to %s", config.assistant:upper()), vim.log.levels.INFO)

        -- popup を開く
        local script_path = vim.fn.expand("~/.config/tmux/scripts/ai-popup.sh")
        vim.fn.jobstart(script_path, {
          env = {
            AI_ASSISTANT = config.assistant,
            NVIM_INSTANCE_ID = tostring(config.instance_id),
            NVIM_CWD = vim.fn.getcwd(),
          },
          on_stderr = function(_, data, _)
            if data and #data > 0 then
              local err = table.concat(data, "\n")
              if err ~= "" then
                vim.notify("AI popup error: " .. err, vim.log.levels.ERROR)
              end
            end
          end,
          on_exit = function(_, code, _)
            if code ~= 0 then
              vim.notify(string.format("AI popup script failed (exit code: %d). Check /tmp/ai-popup-error.log", code), vim.log.levels.ERROR)
            end
          end,
        })
      end
    end
  })
end

-- キーマッピングを設定
-- ノーマルモード: [[ でプロンプト入力
vim.keymap.set('n', '[[', prompt_and_send_to_ai,
  { noremap = true, silent = false, desc = 'Send prompt to AI Assistant (tmux popup)' })

-- ビジュアルモード: [[ で選択テキストを送信
vim.keymap.set('v', '[[', send_selection_to_ai,
  { noremap = true, silent = true, desc = 'Send selection to AI Assistant' })

-- ターミナルモード: [[ でプロンプト入力
vim.keymap.set('t', '[[', function()
  vim.cmd('stopinsert')
  vim.schedule(prompt_and_send_to_ai)
end, { noremap = true, silent = false, desc = 'Send prompt to AI Assistant from terminal mode' })

-- AI Assistant 切り替え: <Space>[[
vim.keymap.set('n', '<Space>[[', switch_ai_assistant,
  { noremap = true, silent = false, desc = 'Switch AI Assistant' })

