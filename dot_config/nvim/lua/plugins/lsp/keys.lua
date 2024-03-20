return function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local opts = { noremap = true, silent = true }
  -- definition
  -- buf_set_keymap('n', '<leader>d', '<Cmd>Lspsaga peek_definition<CR>', opts)
  -- buf_set_keymap('n', '<leader>t', '<Cmd>Lspsaga peek_type_definition<CR>', opts)
  -- buf_set_keymap('n', '<leader>c', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>d', '<Cmd>FzfLua lsp_definitions<CR>', opts)
  buf_set_keymap('n', '<leader>t', '<Cmd>FzfLua lsp_typedefs<CR>', opts)
  buf_set_keymap('n', '<leader>c', '<Cmd>FzfLua lsp_references<CR>', opts)


  -- doc
  buf_set_keymap('n', '<C-h>', '<Cmd>Lspsaga hover_doc<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  -- diagnostics
  -- buf_set_keymap('n', '<leader>ld', '<Cmd>Lspsaga show_line_diagnostics<CR>', opts)
  buf_set_keymap('n', '<leader>ld', '<Cmd>FzfLua lsp_document_diagnostics<CR>', opts)
  -- buf_set_keymap('n', '<leader>lld', '<Cmd>Lspsaga show_workspace_diagnostics<CR>', opts)

  -- rename
  buf_set_keymap('n', '<leader>r', '<Cmd>Lspsaga rename<CR>', opts)

  -- code action
  -- buf_set_keymap('n', '<leader>a', '<Cmd>Lspsaga code_action<CR>', opts)
  buf_set_keymap('n', '<leader>a', '<Cmd>FzfLua lsp_code_actions<CR>', opts)

  -- format
  buf_set_keymap('n', '<leader>f', '<Cmd>lua vim.lsp.buf.format()<CR>', opts)

  -- symbol outline
  buf_set_keymap("n", '<leader>o', '<Cmd>Lspsaga outline<CR>', opts)

  -- other
  buf_set_keymap("n", '<leader><leader>', ':Lspsaga<Space>', opts)
end

-- buf_set_keymap('n', '<leader>d', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
-- buf_set_keymap('n', '<leader>t', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
-- buf_set_keymap('n', '<leader>r', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
-- buf_set_keymap('n', '<leader>a', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
