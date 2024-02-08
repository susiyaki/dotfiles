local mason_lspconfig = require("mason-lspconfig")
local nvim_lsp = require('lspconfig')


-- print('Load lsp')
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

  if server == "tsserver" then
    opts.root_dir = nvim_lsp.util.root_pattern("package.json")
    opts.single_file_support = false
  elseif server == "denols" then
    opts.root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc")
    opts.init_options = {
      lint = true,
      unstable = true,
      suggest = {
        imports = {
          hosts = {
            ["https://deno.land"] = true,
            ["https://cdn.nest.land"] = true,
            ["https://crux.land"] = true
          }
        }
      }
    }
  elseif server == "biome" then
    opts.root_dir = nvim_lsp.util.root_pattern("biome.json")
    opts.single_file_support = false
  elseif server == "eslint" then
    opts.root_dir = nvim_lsp.util.root_pattern("package.json")
  end

  nvim_lsp[server].setup(opts)
end
})
