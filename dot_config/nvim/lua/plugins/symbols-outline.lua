local utils = require('utils')

utils.map('n', '<leader>o', ":SymbolsOutlineOpen<CR>")

vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = false,
    position = 'right',
    keymaps = {
        close = "<Esc>",
        goto_location = "<CR>",
        focus_location = "o",
        hover_symbol = "<C-h>",
        rename_symbol = "r",
        code_actions = "a"
    },
    lsp_blacklist = {}
}