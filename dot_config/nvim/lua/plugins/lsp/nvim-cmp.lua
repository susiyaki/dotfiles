-- Configuration for nvim-compe

local cmp = require'cmp'
local utils = require('utils')
local lspkind = require('lspkind')

vim.cmd [[set shortmess+=c]]
utils.opt('o', 'completeopt', 'menu,menuone,noselect')

local source_mapping = {
	buffer = "[Buffer]",
	nvim_lsp = "[LSP]",
	nvim_lua = "[Lua]",
	cmp_tabnine = "[TN]",
	path = "[Path]",
  vsnip = "[Snippet]"
}

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
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
    ['<C-k>'] = cmp.mapping.confirm({ select = true }),
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
    { name = 'vsnip' },
  }, {
    -- { name = 'cmp_tabnine' },
    { name = 'path' },
    { name = 'buffer' },
  }),
  formatting = {
	  format = function(entry, vim_item)
    	vim_item.kind = lspkind.presets.default[vim_item.kind]
   	local menu = source_mapping[entry.source.name]
   	if entry.source.name == 'cmp_tabnine' then
   		if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
   			menu = entry.completion_item.data.detail .. ' ' .. menu
      end
   		vim_item.kind = ''
    end
    vim_item.menu = menu
    return vim_item
  end
 },
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

-- cmp-tabnine
-- local tabnine = require('cmp_tabnine.config')

-- tabnine:setup({
-- 	max_lines = 1000;
-- 	max_num_results = 20;
-- 	sort = true;
-- 	run_on_every_keystroke = true;
-- 	snippet_placeholder = '..';
-- 	ignored_file_types = { -- default is not to ignore
-- 		-- uncomment to ignore in lua:
-- 		-- lua = true
-- 	};
-- })

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
