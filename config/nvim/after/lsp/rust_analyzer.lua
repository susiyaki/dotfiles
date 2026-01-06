---@type vim.lsp.Config
return {
  settings = {
    ["rust-analyzer"] = {
      imports = {
        granularity = { group = "module" },
        prefix = "self",
      },
      cargo = { buildScripts = { enable = true } },
      procMacro = { enable = true },
    }
  },
  on_attach = function(client, bufnr)
    require 'plugins.lsp.keys' (client, bufnr)
    require 'plugins.lsp.settings'.on_attach(bufnr)
  end,
}
