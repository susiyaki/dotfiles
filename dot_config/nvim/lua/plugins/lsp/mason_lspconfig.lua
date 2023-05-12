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

  local node_root_dir = nvim_lsp.util.root_pattern("package.json")
  local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

  if server == "tsserver" then
    if not is_node_repo then
      return
    end

    opts.root_dir = node_root_dir
  elseif server == "eslint" then
    if not is_node_repo then
      return
    end

    opts.root_dir = node_root_dir
  elseif server == "denols" then
    if is_node_repo then
      return
    end

    opts.root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc", "deps.ts", "import_map.json")
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
  end

  nvim_lsp[server].setup(opts)
end
})
