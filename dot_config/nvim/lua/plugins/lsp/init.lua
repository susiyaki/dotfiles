USER = vim.fn.expand('$USER')

local on_attach = function(client, bufnr)
    -- require'lsp_signature'.on_attach(client)

    require'plugins.lsp.keys'(client, bufnr)
    require'plugins.lsp.settings'.on_attach(bufnr)
end

local nvim_lsp = require('lspconfig')

-- Capabilities
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

-- LSPs
local lsp_installer = require("nvim-lsp-installer")

lsp_installer.on_server_ready(function(server)
    local opts = {capabilities = capabilities, on_attach = on_attach}

    server:setup(opts)
end)

  -- dart
  nvim_lsp.dartls.setup{capabilities = capabilities, on_attach = on_attach}

  -- LSP Enable diagnostics
  vim.lsp.handlers["textDocument/publishDiagnostics"] =
      vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text = false,
          underline = true,
          signs = true,
          update_in_insert = false
      })

-- rust tools
local opts = {
    tools = {
        autoSetHints = true,
        hover_with_actions = true,
        runnables = {
            use_telescope = true
        },
        inlay_hints = {
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },

    server = {
        on_attach = on_attach,
        settings = {
            ["rust-analyzer"] = {
                -- enable clippy on save
                checkOnSave = {
                    command = "clippy"
                },
            }
        }
    },
}

-- require('rust-tools').setup(opts)

vim.api.nvim_command([[
highlight LspDiagnosticsSignError guibg=#a31111 guifg=White
highlight LspDiagnosticsSignWarning guibg=#edc123 guifg=Black
highlight LspDiagnosticsSignHint guibg=#d3cdcd guifg=Black
highlight LspDiagnosticsSignInformation guibg=#20d6c0 guifg=Black
]])
