local M = {}

M.on_attach = function(client, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- document_highlightをサポートしている場合のみ有効化
  if client.server_capabilities.documentHighlightProvider then
    local augroup = vim.api.nvim_create_augroup('LspHighlight', { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      group = augroup,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      group = augroup,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

return M
