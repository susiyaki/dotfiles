local mason_lspconfig = require("mason-lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()

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

local on_attach = function(client, bufnr)
  require 'plugins.lsp.keys' (client, bufnr)
  require 'plugins.lsp.settings'.on_attach(client, bufnr)
end

vim.lsp.config('*', {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Mason-lspconfig setup to ensure servers are installed
mason_lspconfig.setup({
  ensure_installed = {
    "lua_ls",
    "ts_ls",
    "biome",
    "rust_analyzer",
    "jsonls",
  },
  automatic_installation = true,
})

-- 【推奨案】rust-analyzer を mise ラッパー経由で起動
-- mise exec により、プロジェクトの mise.toml で指定された toolchain が使われる
vim.lsp.config('rust_analyzer', {
  cmd = { vim.fn.stdpath('config') .. '/bin/rust-analyzer-mise' },
  root_markers = { 'Cargo.toml', 'rust-toolchain.toml' },
})
