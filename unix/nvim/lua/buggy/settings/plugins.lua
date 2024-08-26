local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua PackerSync
  augroup end
]])

local status, packer = pcall(require, "packer")
if not status then
  return
end

return packer.startup(function(use)
  use 'wbthomason/packer.nvim'                -- Plugin Manager
  ------------------------------------------------------------------------
  use 'windwp/nvim-autopairs'                 -- Auto pair symbols
  use 'nvim-tree/nvim-tree.lua'               -- File manager
  use 'nvim-tree/nvim-web-devicons'           -- Support icon on manager
  use 'lukas-reineke/indent-blankline.nvim'   -- Indent blankline
  use 'Pocco81/auto-save.nvim'                -- Auto save
  use 'ray-x/guihua.lua'                      -- Floating UI
  use 'mfussenegger/nvim-lint'                -- Linting
  use 'tpope/vim-surround'                    -- Parentheses, brackets,
                                              -- quotes, XML tags, 
                                              -- and more
  use 'tpope/vim-commentary'                  -- Commentary tools
  use 'stevearc/dressing.nvim'                -- Dressing 
  ------------------------------------------------------------------------
  --- Development Area
  use 'tpope/vim-fugitive'                    -- Git Intergration
  use 'ray-x/go.nvim'                         -- Golang Development
  use 'folke/lua-dev.nvim'                    -- Lua Development
  use 'mfussenegger/nvim-jdtls'               -- Java Development
  use 'bash-lsp/bash-language-server'         -- Bash Development

  --- HTML and CSS
  use 'mattn/emmet-vim'
  use 'othree/html5.vim'
  use 'hail2u/vim-css3-syntax'

  -- JavaScript/TypeScript
  use 'jose-elias-alvarez/nvim-lsp-ts-utils'
  use 'maxmellon/vim-jsx-pretty'
  use 'HerringtonDarkholme/yats.vim'

  -- C/C++
  use 'jackguo380/vim-lsp-cxx-highlight'

  -- Python
  use 'Vimjas/vim-python-pep8-indent'
  use 'mfussenegger/nvim-dap-python'

  -- Rust
  use 'rust-lang/rust.vim'
  use 'simrat39/rust-tools.nvim'

  -- React/Vue/Angular
  use 'pangloss/vim-javascript'
  use 'MaxMEllon/vim-jsx-pretty'
  use 'leafOfTree/vim-vue-plugin'
  use 'jparise/vim-graphql'
  ------------------------------------------------------------------------
  --- Highlighting Syntax
  --- need install 'node' and 'build-essential' atau 'gcc' atau 'base-devel'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require("nvim-treesitter.install").update { with_sync = true } end
  }
  ------------------------------------------------------------------------
  --- Themes
  use { 'catppuccin/nvim', as = 'catppuccin' }
  use 'ellisonleao/gruvbox.nvim'
  use 'Mofiqul/vscode.nvim'
  use {'akinsho/bufferline.nvim', tag = "*", requires = 'nvim-tree/nvim-web-devicons'}
  ------------------------------------------------------------------------
  --- Language Support
  use {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
  }
  ------------------------------------------------------------------------
  --- Autocompletions
  use {'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',                  -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer',                    -- Buffer completions
      'hrsh7th/cmp-path',                      -- Path completions
      'hrsh7th/cmp-cmdline',                   -- Command line completions
      'L3MON4D3/LuaSnip',                      -- Snippet engine
      'saadparwaiz1/cmp_luasnip'               -- Snippet completions
    }
  }
  ------------------------------------------------------------------------
  --- Statusline
  use { 'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
  -- use { 'feline-nvim/feline.nvim', branch = '0.5-compat' }
  -- use 'freddiehaddad/feline.nvim'
  use 'famiu/feline.nvim'
  use "Hitesh-Aggarwal/feline_one_monokai.nvim"
  ------------------------------------------------------------------------
  --- Search and Find for file, text, etc
  use { 'nvim-telescope/telescope.nvim', tag = '0.1.8',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  ------------------------------------------------------------------------
  --- Git Intergration
  use { "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integrations
      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua",              -- optional
    },
    config = true
  }

  if packer_bootstrap then
    require('packer').sync()
    vim.cmd('source '..vim.fn.stdpath('config')..'/init.lua')
  end
end)

