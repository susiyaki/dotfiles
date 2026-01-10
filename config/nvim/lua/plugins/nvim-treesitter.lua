local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

configs.setup {
  -- よく使う言語だけをインストール
  ensure_installed = {
    "lua",
    "typescript",
    "tsx",
    "javascript",
    "json",
    "html",
    "css",
    "markdown",
    "markdown_inline",
    "vim",
    "vimdoc",
    "bash",
    "yaml",
  },

  -- 自動インストールを無効化（手動管理）
  auto_install = false,

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
