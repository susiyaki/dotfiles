require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    disable =  { "typescript", "typescriptreact" }
  },

  incremental_selection = {
    enable = false
  },

  indent = {
    enable = true
  }
}
