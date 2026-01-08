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
-- ビジュアルモード: 選択テキストをClaudeCodeに送信（バーティカル）
vim.keymap.set('v', ',,', function()
  send_selection_with_position("vertical")
end, { noremap = true, silent = true, desc = "Send selection to ClaudeCode (vertical)" })

-- ノーマルモード: バーティカルでトグル
vim.keymap.set('n', '<Space>,,', function()
  toggle_with_position("vertical")
end, { noremap = true, silent = true, desc = "Toggle ClaudeCode (vertical)" })

-- Claude Code: ,, でポップアップ入力してClaude Codeペインとyankレジスタに反映
local function prompt_and_send_to_claude()
  -- 呼び出し元のウィンドウを記録（フローティングウィンドウを開く前）
  local original_win = vim.api.nvim_get_current_win()

  -- フローティングウィンドウの設定
  local width = 80
  local height = 5
  local buf = vim.api.nvim_create_buf(false, true)

  -- ウィンドウの位置を中央に計算
  local ui = vim.api.nvim_list_uis()[1]
  local win_width = ui.width
  local win_height = ui.height
  local col = math.floor((win_width - width) / 2)
  local row = math.floor((win_height - height) / 2)

  -- フローティングウィンドウを作成
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' Claude Codeに送信 ',
    title_pos = 'center',
  }
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- バッファオプション
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

  -- 送信処理
  local function send_input()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local input = table.concat(lines, '\n')

    -- ウィンドウを閉じる
    vim.api.nvim_win_close(win, true)

    if input and input ~= '' then
      -- yankレジスタに保存（複数のレジスタに保存）
      vim.fn.setreg('"', input, 'c')  -- 無名レジスタ
      vim.fn.setreg('0', input, 'c')  -- yank専用レジスタ
      vim.fn.setreg('+', input, 'c')  -- システムクリップボード
      vim.fn.setreg('*', input, 'c')  -- セレクションクリップボード

      -- Claude Codeのターミナルバッファを探す
      local claude_buf = nil
      local claude_chan = nil

      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) then
          local name = vim.api.nvim_buf_get_name(b)
          -- ターミナルバッファで、'claude'という文字列を含むものを探す
          if vim.bo[b].buftype == 'terminal' and name:lower():match('claude') then
            claude_buf = b
            claude_chan = vim.bo[b].channel
            break
          end
        end
      end

      if claude_chan and claude_chan > 0 then
        -- Claude Codeのウィンドウが表示されているかチェック
        local win_id = vim.fn.bufwinid(claude_buf)

        if win_id == -1 then
          -- バッファは存在するがウィンドウが表示されていない場合は開く
          local claude_code = require("claude-code")
          local original_position = claude_code.config.window.position
          claude_code.config.window.position = "vertical"
          claude_code.toggle()
          claude_code.config.window.position = original_position
        end

        -- ターミナルバッファに送信
        vim.api.nvim_chan_send(claude_chan, input .. '\n')
      else
        -- Claude Codeが開いていない場合は起動してから送信
        local claude_code = require("claude-code")
        local original_position = claude_code.config.window.position
        claude_code.config.window.position = "vertical"
        claude_code.toggle()
        claude_code.config.window.position = original_position

        -- Claude Codeが起動するまで待ってから送信
        vim.defer_fn(function()
          -- 再度ターミナルバッファを探す
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(b) then
              local name = vim.api.nvim_buf_get_name(b)
              if vim.bo[b].buftype == 'terminal' and name:lower():match('claude') then
                local chan = vim.bo[b].channel
                if chan and chan > 0 then
                  vim.api.nvim_chan_send(chan, input .. '\n')
                  vim.notify("Claude Code started and text sent", vim.log.levels.INFO)
                  return
                end
              end
            end
          end
          vim.notify("Failed to send text to Claude Code", vim.log.levels.WARN)
        end, 1000)
      end
    end
  end

  -- キャンセル処理
  local function cancel_input()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- キーマップ設定（バッファローカル）
  -- normalモードでEnterで送信
  vim.keymap.set('n', '<CR>', send_input, {
    buffer = buf,
    noremap = true,
    silent = true,
  })

  -- インサートモードでCtrl+kで送信
  vim.keymap.set('i', '<C-k>', function()
    vim.cmd('stopinsert')
    vim.schedule(function()
      send_input()
      -- 元のウィンドウに戻ってinsertモードを開始
      vim.defer_fn(function()
        if original_win and vim.api.nvim_win_is_valid(original_win) then
          vim.api.nvim_set_current_win(original_win)
          -- nvim_feedkeysを使ってinsertモードに入る（カーソル位置そのまま）
          vim.api.nvim_feedkeys('i', 'n', false)
        end
      end, 10)
    end)
  end, {
    buffer = buf,
    noremap = true,
    silent = true,
  })

  -- Escでキャンセル（インサートモードからノーマルモードへ）
  vim.keymap.set('i', '<Esc>', '<Esc>', {
    buffer = buf,
    noremap = true,
    silent = true,
  })

  -- ノーマルモードでEscでキャンセル
  vim.keymap.set('n', '<Esc>', cancel_input, {
    buffer = buf,
    noremap = true,
    silent = true,
  })

  -- qでキャンセル
  vim.keymap.set('n', 'q', cancel_input, {
    buffer = buf,
    noremap = true,
    silent = true,
  })

  -- インサートモードで開始
  vim.cmd('startinsert')
end

-- ノーマルモード: ,, でポップアップ
vim.keymap.set('n', ',,', prompt_and_send_to_claude, { noremap = true, silent = false, desc = 'Send input to Claude Code pane and yank register' })

-- ターミナルモード: ,, でポップアップ（ターミナルモードを抜けてから実行）
vim.keymap.set('t', ',,', function()
  vim.cmd('stopinsert')  -- ターミナルモードを抜ける
  vim.schedule(prompt_and_send_to_claude)  -- ノーマルモードになってから実行
end, { noremap = true, silent = false, desc = 'Send input to Claude Code pane from terminal mode' })

-- Neovim起動時にClaude Codeをバックグラウンドで自動起動
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    -- 少し遅延させてから起動（他のプラグインの初期化を待つ）
    vim.defer_fn(function()
      local claude_code = require("claude-code")
      -- 既にClaude Codeが起動しているかチェック
      local current_instance = claude_code.claude_code.current_instance
      local bufnr = current_instance and claude_code.claude_code.instances[current_instance]

      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        -- バックグラウンドで起動（verticalで起動）
        local original_position = claude_code.config.window.position
        claude_code.config.window.position = "vertical"
        claude_code.toggle()
        -- すぐに非表示にする（バックグラウンド化）
        vim.defer_fn(function()
          claude_code.toggle()
          claude_code.config.window.position = original_position
        end, 100)
      end
    end, 500)
  end,
  once = true,  -- 一度だけ実行
})

