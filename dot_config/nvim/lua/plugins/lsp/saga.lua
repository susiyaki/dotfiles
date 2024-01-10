local saga = require 'lspsaga'
local utils = require 'utils'

require("lspsaga").setup({
  diagnostic = {
    show_code_action = true,
    jump_num_shortcut = true
  },
  lightbulb = {
    sign = false
  },
  ui = {
    code_action = ''
  }
})
