vim.cmd('colorscheme gruvbox')

-- Make Neovim background transparent to reflect tmux pane colors
local groups = { "Normal", "NonText", "LineNr", "SignColumn", "EndOfBuffer" }
for _, group in ipairs(groups) do
  vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
end
