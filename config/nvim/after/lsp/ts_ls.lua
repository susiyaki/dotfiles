---@type vim.lsp.Config
return {
  root_markers = { "package.json" },
  workspace_required = true,
  on_attach = function(client, bufnr)
    require 'plugins.lsp.keys' (client, bufnr)
    require 'plugins.lsp.settings'.on_attach(bufnr)
  end,
}
