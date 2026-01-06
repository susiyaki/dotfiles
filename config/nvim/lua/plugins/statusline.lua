local colors = {
  normal      = '#ff9900',
  insert      = '#67efeb',
  replace     = '#fc5555',
  visual      = '#9454c9',
  command     = '#e8e847',
  terminal    = '#000000',

  none        = '#3b3b3b',

  bg          = '#1b1b1b',
  fg          = '#ffffff',
  fgh         = '#000000',

  lsp_active  = '#00ffbf'
}

local mode_map = {
  ['n'] = {'NORMAL', colors.normal},
  ['i'] = {'INSERT', colors.insert},
  ['R'] = {'REPLACE', colors.replace},
  ['v'] = {'VISUAL', colors.visual},
  ['V'] = {'V-LINE', colors.visual},
  ['c'] = {'COMMAND', colors.command},
  ['s'] = {'SELECT', colors.visual},
  ['S'] = {'S-LINE', colors.visual},
  ['t'] = {'TERMINAL', colors.terminal},
  [''] = {'V-BLOCK', colors.visual},
  [''] = {'S-BLOCK', colors.visual},
  ['Rv'] = {'VIRTUAL'},
  ['rm'] = {'--MORE'},
}

local sep = {
  -- right_filled = '▐',
  -- left_filled = '▌',
  right_filled = '',
  left_filled = '',
  right = '┃',
  left = '┃',
-- right = ' ',
-- left = '',
}

local icons = {
  locker = '' ,
  unsaved = '⚉',
  dos = '',
  unix = '',
  mac = '',
  lsp_status = '☍'
}

local theme = {
  normal = {
    a = { bg = colors.normal, fg = colors.fgh, gui = 'bold' },
    b = { bg = colors.none, fg = colors.fg },
    c = { bg = colors.none, fg = colors.fg },
  },
  insert = {
    a = { bg = colors.insert, fg = colors.fgh, gui = 'bold' },
    b = { bg = colors.none, fg = colors.fg },
    c = { bg = colors.none, fg = colors.fg },
  },
  visual = {
    a = { bg = colors.visual, fg = colors.fgh, gui = 'bold' },
    b = { bg = colors.none, fg = colors.fg },
    c = { bg = colors.none, fg = colors.fg },
  },
  replace = {
    a = { bg = colors.replace, fg = colors.fgh, gui = 'bold' },
    b = { bg = colors.none, fg = colors.fg },
    c = { bg = colors.none, fg = colors.fg },
  },
  command = {
    a = { bg = colors.command, fg = colors.fgh, gui = 'bold' },
    b = { bg = colors.none, fg = colors.fg },
    c = { bg = colors.none, fg = colors.fg },
  },
  terminal = {
    a = { bg = colors.terminal, fg = colors.fg, gui = 'bold' },
    b = { bg = colors.none, fg = colors.fg },
    c = { bg = colors.none, fg = colors.fg },
  },
  inactive = {
    a = { bg = colors.none, fg = colors.fg },
    b = { bg = colors.none, fg = colors.none },
    c = { bg = colors.none, fg = colors.none },
  },
}

local function lsp_status()
  local connected = not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0 }))
  if connected then
    return icons.lsp_status
  else
    return ''
  end
end

local function filetype()
  return vim.bo.filetype
end

require('lualine').setup({
  options = {
    theme = theme,
    component_separators = sep.right,
    section_separators = { left = sep.left, right =  sep.right }
  },
  sections = {
    lualine_a = {
      'mode'
    },
    lualine_b = {
      {
        'filename',
        path = 1
      }
    },
    lualine_c = { },
    lualine_x = {
      {
        lsp_status,
        colors = { fg = colors.lsp_active, bg = colors.none },
        separator = {  }
      },
      {
        'diagnostics',
        sources = { 'nvim_lsp' },
      },
    },
    lualine_y = {
      {
        filetype,
      }
    },
    lualine_z = {
      'progress',
      'location',
    }
  },
  inactive_sections = {
    lualine_a = {
      {
        'filename',
        path = 2
      }
    },
    lualine_b = { },
    lualine_c = { },
    lualine_x = { },
    lualine_y = { },
    lualine_z = {
      'filetype'
    }
  }
})
