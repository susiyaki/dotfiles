return function(client, bufnr)
  local opts = { noremap = true, silent = true }

  -- Definition and navigation
  vim.keymap.set('n', '<leader>d', '<Cmd>Lspsaga peek_definition<CR>', opts)
  -- vim.keymap.set('n', '<leader>t', '<Cmd>Lspsaga peek_type_definition<CR>', opts)
  -- vim.keymap.set('n', '<leader>c', '<Cmd>Lspsaga finder<CR>', opts)

  -- Hover and help
  vim.keymap.set('n', '<C-h>', '<Cmd>Lspsaga hover_doc<CR>', opts)
  vim.keymap.set('n', 'K', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  -- Diagnostics
  vim.keymap.set('n', '<leader>ld', '<Cmd>Lspsaga show_line_diagnostics<CR>', opts)
  vim.keymap.set('n', '<leader>]]', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
  vim.keymap.set('n', '<leader>][', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
  -- vim.keymap.set('n', '<leader>lld', '<Cmd>Lspsaga show_workspace_diagnostics<CR>', opts)

  -- Code actions and refactoring
  vim.keymap.set('n', '<leader>r', '<Cmd>Lspsaga rename<CR>', opts)
  -- vim.keymap.set('n', '<leader>a', '<Cmd>Lspsaga code_action<CR>', opts)

  -- Formatting (will be handled by none-ls if available)
  if client.supports_method('textDocument/formatting') then
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end

  -- Symbol outline
  vim.keymap.set("n", '<leader>o', '<Cmd>Lspsaga outline<CR>', opts)

  -- Lspsaga command palette
  vim.keymap.set("n", '<leader><leader>', ':Lspsaga<Space>', opts)
  
  -- LSP restart
  vim.keymap.set('n', '<leader>]r', ':LspRestart<CR>', opts)
end

