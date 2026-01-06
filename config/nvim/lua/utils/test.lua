local utils = require('utils')

vim.g.test_command = ""

local function execute_test()
  if vim.g.test_command == "" then
    vim.g.test_command = vim.fn.input('Please enter the test command: ')
  end

  local current_file = vim.fn.expand('%:p')

  vim.cmd(string.format('vert term %s %s', vim.g.test_command, current_file))
end

-- テストコマンド変更関数
local function change_test_command()
  vim.g.test_command = vim.fn.input('Please enter the new test command: ')
  print("\nTest command has been changed: " .. vim.g.test_command)
end

utils.map("n", "<Leader>t", ":TestExecute<CR>")
utils.map("n", "<Leader>ct", ":TestChangeCommand<CR>")

vim.api.nvim_create_user_command("TestExecute", execute_test, {})
vim.api.nvim_create_user_command("TestChangeCommand", change_test_command, {})
