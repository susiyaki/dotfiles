require("claude-code").setup({
  window = {
    position = "vertical"
  }
})

-- 指定した position でトグルする関数
local function toggle_with_position(position)
  local claude_code = require("claude-code")
  local original_position = claude_code.config.window.position

  -- 一時的に position を変更
  claude_code.config.window.position = position

  -- トグル実行
  claude_code.toggle()

  -- position を元に戻す
  claude_code.config.window.position = original_position
end

-- ビジュアルモード選択テキストをClaudeCodeに送信し、選択範囲を削除する関数
local function send_selection_with_position(position)
  -- ビジュアルモードを抜ける前に選択範囲を記録
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg('v')

  -- 選択範囲を削除
  vim.cmd("normal! gvd")

  local claude_code = require("claude-code")

  -- Claude Codeが開いているかチェック
  local current_instance = claude_code.claude_code.current_instance
  local bufnr = current_instance and claude_code.claude_code.instances[current_instance]

  local function send_text_to_claude()
    current_instance = claude_code.claude_code.current_instance
    bufnr = current_instance and claude_code.claude_code.instances[current_instance]

    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
      vim.notify("Claude Code terminal not found", vim.log.levels.ERROR)
      return
    end

    -- ターミナルチャンネルIDを取得してテキストを送信
    local chan_id = vim.bo[bufnr].channel
    if chan_id then
      vim.fn.chansend(chan_id, selected_text .. '\n')
      vim.notify("Text sent to Claude Code", vim.log.levels.INFO)
    else
      vim.notify("Could not find Claude Code terminal channel", vim.log.levels.ERROR)
    end
  end

  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    -- Claude Codeを指定したpositionで開いてから送信
    local original_position = claude_code.config.window.position
    claude_code.config.window.position = position
    claude_code.toggle()
    claude_code.config.window.position = original_position
    vim.defer_fn(send_text_to_claude, 500)
  else
    send_text_to_claude()
  end
end

-- キーマッピングを設定
-- ビジュアルモード: 選択テキストをClaudeCodeに送信（フローティング）
vim.keymap.set('v', ',,', function()
  send_selection_with_position("float")
end, { noremap = true, silent = true, desc = "Send selection to ClaudeCode (floating)" })

-- ビジュアルモード: 選択テキストをClaudeCodeに送信（バーティカル）
vim.keymap.set('v', '<Space>,v', function()
  send_selection_with_position("vertical")
end, { noremap = true, silent = true, desc = "Send selection to ClaudeCode (vertical)" })

-- ノーマルモード: フローティングでトグル
vim.keymap.set('n', '<Space>,,', function()
  toggle_with_position("float")
end, { noremap = true, silent = true, desc = "Toggle ClaudeCode (floating)" })

-- ノーマルモード: バーティカルでトグル
vim.keymap.set('n', '<Space>,v', function()
  toggle_with_position("vertical")
end, { noremap = true, silent = true, desc = "Toggle ClaudeCode (vertical)" })

-- Claude Code: ,, でポップアップ入力してClaude Codeペインとyankレジスタに反映
vim.keymap.set('n', ',,', function()
  vim.ui.input({ prompt = 'Claude Codeに送信: ' }, function(input)
    if input and input ~= '' then
      -- yankレジスタに保存（複数のレジスタに保存）
      vim.fn.setreg('"', input, 'c')  -- 無名レジスタ
      vim.fn.setreg('0', input, 'c')  -- yank専用レジスタ
      vim.fn.setreg('+', input, 'c')  -- システムクリップボード
      vim.fn.setreg('*', input, 'c')  -- セレクションクリップボード

      -- Claude Codeのターミナルバッファを探す
      local claude_buf = nil
      local claude_chan = nil

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
          local name = vim.api.nvim_buf_get_name(buf)
          -- ターミナルバッファで、'claude'という文字列を含むものを探す
          if vim.bo[buf].buftype == 'terminal' and name:lower():match('claude') then
            claude_buf = buf
            claude_chan = vim.bo[buf].channel
            break
          end
        end
      end

      if claude_chan and claude_chan > 0 then
        -- ターミナルバッファに送信
        vim.api.nvim_chan_send(claude_chan, input .. '\n')
        print('Claude Codeに送信しました (レジスタにも保存): ' .. input)
      else
        print('Claude Codeのターミナルバッファが見つかりません（レジスタには保存されました）')
      end
    end
  end)
end, { noremap = true, silent = false, desc = 'Send input to Claude Code pane and yank register' })

