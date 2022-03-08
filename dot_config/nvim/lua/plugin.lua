vim.cmd([[packadd packer.nvim]])
return require('packer').startup(
  function(use)
    use {'wbthomason/packer.nvim', opt = true}

    -- Filer
    use {
      'Shougo/defx.nvim',
      requires = {
        'roxma/nvim-yarp',
        'roxma/vim-hug-neovim-rpc',
        'ryanoasis/vim-devicons',
        'kristijanhusak/defx-icons',
        'kristijanhusak/defx-git'
      },
      config = function() require'plugins.defx' end
    }

    -- FuzzyFinder
    use {
      'junegunn/fzf.vim',
      requires = {
        {
          'junegunn/fzf',
          run = './install --all',
        }
      },
      setup = function() require'plugins.fzf' end
    }

    -- Git
    use {
      'airblade/vim-gitgutter',
      {
        'tpope/vim-fugitive',
        setup = function() require'plugins.vim-fugitive' end,
      },
    }

    -- LSP
    use {
      {
        'neovim/nvim-lspconfig',
        requires = {
          'folke/lua-dev.nvim',
          'williamboman/nvim-lsp-installer'
        },
        config = function() require'plugins.lsp' end
      },

      {
        'glepnir/lspsaga.nvim',
        config = function() require'plugins.lsp.saga' end
      },

      -- completion
      {
        'hrsh7th/nvim-cmp',
        config = function() require'plugins.lsp.nvim-cmp' end,
      },
      'onsails/lspkind-nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
      {
        'tzachar/cmp-tabnine',
        run = './install.sh',
      },

      {
        'j-hui/fidget.nvim',
        config = function() require'fidget'.setup{} end
      },


      -- symbol outline
      {
        'simrat39/symbols-outline.nvim',
        setup = function() require'plugins.symbols-outline' end
      },

      -- lsp_signature
      'ray-x/lsp_signature.nvim',

      -- formatter
      {
        'sbdchd/neoformat',
        config = function() require'plugins.lsp.neoformat' end
      }
    }

    -- StatusLine
    use {
      'nvim-lualine/lualine.nvim',
      config = function() require'plugins.statusline' end,
      requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    use {
      -- [auto-pairs]: auto pairs
      'jiangmiao/auto-pairs',

      -- [dial.nvim]
      {
        'monaqa/dial.nvim',
        setup = function() require'plugins.dial' end
      },

      -- [skkeleton.vim]
      {
        'vim-skk/skkeleton',
        config = function() require('plugins.skkeleton') end,
        requires = {
          'vim-denops/denops.vim'
        }
      },

      -- [gruvbox]: colorscheme
      {
        'morhetz/gruvbox',
        setup = function() require('plugins.colorscheme') end
      },

      -- [nvim-bfq]: enhance quickfix
      'kevinhwang91/nvim-bqf',

      -- [nvim-treesitter]: syntax highlight
      {
        'nvim-treesitter/nvim-treesitter',
        config = function() require('plugins.nvim-treesitter') end
      },

      -- [vim-indent-guide]: visualize indent
      {
        'nathanaelkane/vim-indent-guides',
        setup = function() require'plugins.vim-indent-guide' end
      },

      -- [vim-quickrun]
      {
        'thinca/vim-quickrun',
        setup = function() require'plugins.vim-quickrun' end
      },

      -- [vim-surround]:
      'tpope/vim-surround',

      -- [tcomment_vim]
      {
        'tomtom/tcomment_vim',
        setup = function() require'plugins.tcomment_vim' end
      },

      -- [vim-trailing-whitespace]: visualize white space
      {
        'bronson/vim-trailing-whitespace',
        setup = function() require'plugins.vim-trailing-whitespace' end,
      },

      -- [switch.vim]: toggle boolean
      {
        'AndrewRadev/switch.vim',
        setup = function() require'plugins.switch' end
      },

      -- [winresizer]: window resizer
      'simeji/winresizer',

      -- [yankround.vim]: enhaunce yank
      {
        'LeafCage/yankround.vim',
        setup = function() require'plugins.yankround' end
      },

      -- [vimproc]
      {
        'Shougo/vimproc.vim',
      }
    }

    local web_dev_file_types = {
      'html',
      'css',
      'eruby',
      'javascript',
      'typescript',
      'javascript.jsx',
      'typescript.tsx',
      'xml'
    }

    -- Lazy
      -- web develop
    use {
      {
        -- [emmet-vim]
        {
          'mattn/emmet-vim',
          setup = function() require'plugins.emmet' end
        },
        -- [vim-coloresque]
        'gko/vim-coloresque',
        ft = web_dev_file_types,
      },

      -- markdown
      {
        -- [vim-table-mode]
        {
          'dhruvasagar/vim-table-mode',
          setup = function() require'plugins.vim-table-mode' end
        },

        {
          'kat0h/bufpreview.vim',
          requires = {
            'vim-denops/denops.vim'
          }
        },
        ft = { 'markdown' }
      },
    }
  end
)
