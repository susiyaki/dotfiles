USER = vim.fn.expand('$USER')

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local null_ls = require('null-ls')
local mason_null_ls = require("mason-null-ls")
local nvim_lsp = require('lspconfig')

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
  automatic_setup = true
})
mason_null_ls.setup_handlers()

-- lsp config
local on_attach = function(client, bufnr)
  require 'plugins.lsp.keys' (client, bufnr)
  require 'plugins.lsp.settings'.on_attach(bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Code actions
capabilities.textDocument.codeAction = {
  dynamicRegistration = true,
  codeActionLiteralSupport = {
    codeActionKind = {
      valueSet = (function()
        local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
        table.sort(res)
        return res
      end)()
    }
  }
}

capabilities.textDocument.completion.completionItem.snippetSupport = true;

mason_lspconfig.setup_handlers({ function(server)
  local opts = { capabilities = capabilities, on_attach = on_attach }

  nvim_lsp[server].setup(opts)
end
})


-- LSP Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] =
vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = false,
  underline = true,
  signs = true,
  update_in_insert = false
})

vim.api.nvim_command([[
highlight LspDiagnosticsSignError guibg=#a31111 guifg=White
highlight LspDiagnosticsSignWarning guibg=#edc123 guifg=Black
highlight LspDiagnosticsSignHint guibg=#d3cdcd guifg=Black
highlight LspDiagnosticsSignInformation guibg=#20d6c0 guifg=Black
]])
