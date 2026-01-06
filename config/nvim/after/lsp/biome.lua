---@type vim.lsp.Config
return {
  root_markers = { "biome.json" },
  on_attach = function(client, bufnr)
    require 'plugins.lsp.keys' (client, bufnr)
    require 'plugins.lsp.settings'.on_attach(bufnr)
  end,
}
