local devicons = require 'nvim-web-devicons'

local cl = {
  normal = '#ff9900',
  insert = '#67efeb',
  replace = '#fc5555',
  visual = '#9454c9',
  command = '#e8e847',
  terminal = '#000000',

  none = '#3b3b3b',

  bg = '#1b1b1b',
  fg = '#ffffff',
  fgh = '#000000',

  lsp_active = '#00ffbf'
}

local mode_map = {
  ['n'] = {'NORMAL', cl.normal},
  ['i'] = {'INSERT', cl.insert},
  ['R'] = {'REPLACE', cl.replace},
  ['v'] = {'VISUAL', cl.visual},
  ['V'] = {'V-LINE', cl.visual},
  ['c'] = {'COMMAND', cl.command},
  ['s'] = {'SELECT', cl.visual},
  ['S'] = {'S-LINE', cl.visual},
  ['t'] = {'TERMINAL', cl.terminal},
  [''] = {'V-BLOCK', cl.visual},
  [''] = {'S-BLOCK', cl.visual},
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
  unsaved = '',
  dos = '',
  unix = '',
  mac = '',
  lsp_status = ''
}

local pornhub_theme = {
  normal = { a = { fg = cl.fgh, bg = cl.normal } },
  insert = { a = { fg = cl.fgh, bg = cl.insert } },
  visual = { a = { fg = cl.fgh, bg = cl.visual } },
  replace = { a = { fg = cl.fgh, bg = cl.replace } },
  command = { a = { fg = cl.fgh, bg = cl.command } },
  terminal = { a = { fg = cl.fg, bg = cl.terminal } },

  inactive = {
    a = { fg = cl.fg, bg = cl.none },
    b = { fg = cl.fg, bg = cl.none },
    c = { fg = cl.fg, bg = cl.none },
  }
}

local function lsp_status()
  local connected = not vim.tbl_isempty(vim.lsp.buf_get_clients(0))
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
    theme = pornhub_theme,
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
        color = { fg = cl.lsp_active, bg = cl.none },
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
