return require('lazy').setup({
  -- Filer
  {
    "Shougo/defx.nvim",
    dependencies = {
      { "roxma/nvim-yarp" },
      { "roxma/vim-hug-neovim-rpc" },
      { "ryanoasis/vim-devicons" },
      { "kristijanhusak/defx-icons" },
      { "kristijanhusak/defx-git" }
    },
    keys = {
      { "<C-w>", ':<C-U>:Defx -resume -split=vertical -vertical_preview -buffer-name=`"defx " . tabpagenr()`<CR>', silent = true }
    },
    config = function() require 'plugins.defx' end
  },

  -- AI

  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function() require 'plugins.copilot' end
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end
  },

  -- AI Assistant integration (custom, no plugin dependency)
  {
    dir = vim.fn.stdpath("config") .. "/lua/plugins",
    name = "ai-assistant",
    lazy = false,
    config = function() require 'plugins.ai-assistant' end,
  },


  -- UI Enhancement
  {
    "stevearc/dressing.nvim",
    lazy = false,
    priority = 100,
    opts = {
      input = {
        enabled = true,
        default_prompt = "Input:",
        win_options = {
          winblend = 10,
        },
      },
      select = {
        enabled = false,  -- Use fzf-lua for select
      },
    },
  },

  -- Fuzzy Finder
  {
    {
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("fzf-lua").setup({
          winopts = {
            width = 0.9,
            preview = {
              title = true,
            },
          },
          files = {
            formatter = "path.filename_first",
            path_shorten = true,
          },
          git_files = {
            formatter = "path.filename_first",
            path_shorten = true,
          },
          grep = {
            formatter = "path.filename_first",
            path_shorten = true,
          },
          live_grep = {
            formatter = "path.filename_first",
            path_shorten = true,
          },
          keymap = {
            builtin = {
              -- Ctrl-kをプレビューの上移動にバインド
              ["<C-k>"] = "preview-page-up",
              -- Ctrl-jをプレビューの下移動にバインド
              ["<C-j>"] = "preview-page-down",
              -- Ctrl-fをモーダルサイズのトグルにバインド
              ["<C-f>"] = "toggle-fullscreen",
            }
          }
        })
        require("fzf-lua").register_ui_select()
      end,
      keys = {
        { "<C-]><C-g>",     ":FzfLua git_files<CR>",              noremap = true, silent = true },
        { "<C-]><C-f>",     ":FzfLua files<CR>",                  noremap = true, silent = true },
        { "<C-]><C-b>",     ":FzfLua buffers<CR>",                noremap = true, silent = true },
        { "<C-g><C-g>",     ":FzfLua live_grep resume=true<CR>",  noremap = true, silent = true },
        { "<C-g><C-w>",     ":FzfLua grep_cword resume=true<CR>", noremap = true, silent = true },
        { "<C-]><C-Space>", ":FzfLua<CR>",                        noremap = true, silent = true },
        { "<C-]><C-]>",     ":FzfLua resume<CR>",                 noremap = true, silent = true },
        -- LSP
        { "<leader>c",      ":FzfLua lsp_references<CR>",         noremap = true, silent = true },
        { "<leader>a",      ":FzfLua lsp_code_actions<CR>",       noremap = true, silent = true },
      }
    }
  },

  -- Git
  { "airblade/vim-gitgutter" },
  {
    "tpope/vim-fugitive",
    config = function() require 'plugins.vim-fugitive' end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = function() require 'plugins.lsp.nvim-cmp' end,
    dependencies = {
      { "onsails/lspkind-nvim" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-vsnip" },
      { "hrsh7th/vim-vsnip" },
      { "hrsh7th/vim-vsnip-integ" },
      { "j-hui/fidget.nvim" },
    }
  },

  -- LSP
  {
    "glepnir/lspsaga.nvim",
    config = function() require 'plugins.lsp.saga' end,
    dependencies = {
      "neovim/nvim-lspconfig",
      dependencies = {
        { "folke/lua-dev.nvim" },
        { "mason-org/mason.nvim" },
        { "mason-org/mason-lspconfig.nvim" },
        {
          "nvimtools/none-ls.nvim",
          dependencies = {
            "nvim-lua/plenary.nvim"
          }
        },
        { "jay-babu/mason-null-ls.nvim" },
      },
      config = function() require 'plugins.lsp' end,
      ft = {
        "typescript",
        "typescriptreact",
        "lua"
      }
    }
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    config = function() require 'plugins.statusline' end,
  },

  -- Input
  {
    "vim-skk/skkeleton",
    dependencies = {
      { "vim-denops/denops.vim" }
    },
    config = function() require('plugins.skkeleton') end,
  },

  -- Utilities
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>",  "<Plug>(dial-increment)",  mode = { "n", "v" } },
      { "<C-x>",  "<Plug>(dial-decrement)",  mode = { "n", "v" } },
      { "g<C-a>", "g<Plug>(dial-increment)", mode = { "n", "v" } },
      { "g<C-x>", "g<Plug>(dial-decrement)", mode = { "n", "v" } },
    }
  },
  {
    "morhetz/gruvbox",
    config = function() require('plugins.colorscheme') end
  },
  { "kevinhwang91/nvim-bqf" },
  {
    "hrsh7th/nvim-insx",
    config = function() require('plugins.nvim-insx') end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function() require('plugins.nvim-treesitter') end
  },
  {
    "nathanaelkane/vim-indent-guides",
    config = function() require('plugins.vim-indent-guide') end
  },
  { "tpope/vim-surround" },
  { "tomtom/tcomment_vim" },
  {
    "bronson/vim-trailing-whitespace",
    config = function() require('plugins.vim-trailing-whitespace') end
  },
  {
    "AndrewRadev/switch.vim",
    keys = {
      { "<Leader>s", ":Switch<CR>" }
    }
  },
  { "simeji/winresizer" },
  {
    "LeafCage/yankround.vim",
    keys = {
      { "p",     "<Plug>(yankround-p)",   mode = { "n", "x" } },
      { "P",     "<Plug>(yankround-P)" },
      { "gp",    "<Plug>(yankround-gp)",  mode = { "n", "x" } },
      { "gP",    "<Plug>(yankround-gP)" },
      { "<C-p>", "<Plug>(yankround-prev)" },
      { "<C-n>", "<Plug>(yankround-next)" }
    }
  },
  { "Shougo/vimproc.vim" },
  { "gko/vim-coloresque" },
  {
    "shellRaining/hlchunk.nvim",
    event = "UIEnter",
    config = function() require('plugins.hlchunk') end
  },

  -- Web
  {
    "mattn/emmet-vim",
    init = function() require('plugins.emmet') end,
    ft = {
      "html",
      "css",
      "eruby",
      'javascriptreact',
      'typescriptreact',
      "xml"
    }
  },

  -- Markdown
  {
    "dhruvasagar/vim-table-mode",
    config = function() require('plugins.vim-table-mode') end,
    ft = { "markdown" }
  },
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
  },
  { "mpas/marp-nvim" }
})
