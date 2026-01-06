local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.biome.with({
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
        "css",
      },
      condition = function(utils)
        return utils.root_has_file("biome.json")
      end,
    }),
  },
})