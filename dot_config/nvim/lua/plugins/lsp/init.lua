USER = vim.fn.expand('$USER')

local mason = require("mason")
local null_ls = require('null-ls')
local mason_null_ls = require("mason-null-ls")

mason.setup()

null_ls.setup()
mason_null_ls.setup({
  ensure_installed = {
    -- linter
    'markdownlint',
    'misspell',
    'shellcheck',
    -- formatter
    'jq',
    'markdownlint',
    'prettier',
    'shfmt',
  },
  automatic_installation = true,
  automatic_setup = true,
  handlers = {}
})

require('plugins.lsp.mason_lspconfig')

-- LSP Enable diagnostics
-- vim.lsp.handlers["textDocument/publishDiagnostics"] =
-- vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
--   virtual_text = false,
--   underline = true,
--   signs = true,
--   update_in_insert = false
-- })

-- vim.api.nvim_command([[
-- highlight LspDiagnosticsSignError guibg=#a31111 guifg=White
-- highlight LspDiagnosticsSignWarning guibg=#edc123 guifg=Black
-- highlight LspDiagnosticsSignHint guibg=#d3cdcd guifg=Black
-- highlight LspDiagnosticsSignInformation guibg=#20d6c0 guifg=Black
-- ]])
