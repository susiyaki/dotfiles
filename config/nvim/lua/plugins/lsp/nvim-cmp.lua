-- Configuration for nvim-compe

local cmp = require 'cmp'
local utils = require('utils')
local lspkind = require('lspkind')

vim.cmd [[set shortmess+=c]]
utils.opt('o', 'completeopt', 'menu,menuone,noselect')

local source_mapping = {
  buffer = "[Buffer]",
  nvim_lsp = "[LSP]",
  nvim_lua = "[Lua]",
  path = "[Path]",
  vsnip = "[Snippet]",
  copilot = "[Copilot]",
}

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),    -- 補完メニューに枠線を付ける
    documentation = cmp.config.window.bordered(), -- プレビューポップアップに枠線を付ける
  },
  mapping = {
    ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-8), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(8), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<C-k>'] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.confirm({ select = true })
      else
        fallback()
      end
    end),
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "c" }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "c" }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = "copilot" },
    { name = 'vsnip' },
  }, {
    { name = 'path' },
    { name = 'buffer' },
  }),
  formatting = {
    format = function(entry, vim_item)
      local kind = lspkind.cmp_format({
        mode = "symbol_text",
        maxwidth = 50,
        ellipsis_char = "...",
        preset = "codicons",
        symbol_map = { Copilot = "" },
      })(entry, vim_item)
      kind.menu = source_mapping[entry.source.name] or ""
      return kind
    end,
  }
})

cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' }
  })
})

-- vnip
-- Expand or jump
utils.map('i', '<C-k>', "vsnip#expandable()  ? '<Plug>(vsnip-expand)' : '<C-k>'", { noremap = false, expr = true })
utils.map('s', '<C-k>', "vsnip#expandable()  ? '<Plug>(vsnip-expand)' : '<C-k>'", { noremap = false, expr = true })
-- Jump forward or back
utils.map('i', '<C-j>', "vsnip#available(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'", { noremap = false, expr = true })
utils.map('s', '<C-j>', "vsnip#available(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'", { noremap = false, expr = true })
utils.map('i', '<C-l>', "vsnip#available(1)  ? '<Plug>(vsnip-jump-prev)' : '<C-l>'", { noremap = false, expr = true })
utils.map('s', '<C-l>', "vsnip#available(1)  ? '<Plug>(vsnip-jump-prev)' : '<C-l>'", { noremap = false, expr = true })
-- Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
utils.map('x', '<C-j>', "<Plug>(vsnip-select-text)<ESC>", { noremap = false, expr = false })
utils.map('x', '<C-l>', "<Plug>(vsnip-cut-text)<ESC>", { noremap = false, expr = false })

vim.cmd([[
  let g:vsnip_filetypes = {}
  let g:vsnip_filetypes.javascriptreact = ['javascript']
  let g:vsnip_filetypes.typescript = ['javascript']
  let g:vsnip_filetypes.typescriptreact = ['javascript','typescript']
]])
