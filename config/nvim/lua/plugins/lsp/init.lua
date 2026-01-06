local mason = require("mason")

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require('plugins.lsp.mason_lspconfig')
require('plugins.lsp.none-ls')
