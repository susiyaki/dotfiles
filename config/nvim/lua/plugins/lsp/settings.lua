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

  -- Rustファイル保存時にLSPを即座に更新
  if client.name == 'rust_analyzer' then
    vim.api.nvim_create_autocmd('BufWritePost', {
      buffer = bufnr,
      callback = function()
        -- didSaveイベントを明示的に送信
        vim.lsp.buf_notify(bufnr, 'textDocument/didSave', {
          textDocument = {
            uri = vim.uri_from_bufnr(bufnr),
          },
        })
      end,
    })
  end
end

return M
