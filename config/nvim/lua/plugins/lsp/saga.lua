require("lspsaga").setup({
  ui = {
    code_action = '',
    hover = '',
    diagnostic = '',
    incoming = '',
    outgoing = '',
  },
  diagnostic = {
    show_code_action = true,
    jump_num_shortcut = true,
    max_width = 0.7,
    max_height = 0.6,
    text_hl_follow = false,
    border_follow = true,
    keys = {
      exec_action = 'o',
      quit = 'q',
    },
  },
  code_action = {
    num_shortcut = true,
    show_server_name = true,
    keys = {
      quit = 'q',
      exec = '<CR>',
    },
  },
  lightbulb = {
    enable = false,
    sign = false,
  },
  definition = {
    keys = {
      edit = 'o',
      vsplit = '<C-c>v',
      split = '<C-c>i',
      tabe = '<C-c>t',
      quit = 'q',
    },
  },
  rename = {
    quit = '<C-c>',
    exec = '<CR>',
    in_select = true,
  },
  outline = {
    win_position = 'right',
    win_with = '',
    win_width = 30,
    keys = {
      jump = 'o',
      expand_collapse = 'u',
      quit = 'q',
    },
  },
  finder = {
    keys = {
      jump_to = 'p',
      expand = '<CR>',
      vsplit = 's',
      split = 'i',
      tabe = 't',
      tabnew = 'r',
      quit = { 'q', '<ESC>' },
    },
  },
})
