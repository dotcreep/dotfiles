local packer = require('packer')

packer.startup(function(use)
  use 'wbthomason/packer.nvim'           -- Plugin manager
  -- Begin Custom Plugin
  use 'windwp/nvim-autopairs'            -- 1
  use 'neovim/nvim-lspconfig'            -- 2
    -- Begin Autocompleting
    use 'hrsh7th/nvim-cmp'               -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp'           -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-buffer'             -- Buffer completions
    use 'hrsh7th/cmp-path'               -- Path completions
    use 'hrsh7th/cmp-cmdline'            -- Command line completions
    use 'L3MON4D3/LuaSnip'               -- Snippet engine
    use 'saadparwaiz1/cmp_luasnip'       -- Snippet completions
    use 'neovim/nvim-lspconfig'          -- LSP configurations
    -- End Autocompleting
    -- Begin File Explorer
    use 'nvim-tree/nvim-tree.lua'        -- Tree in nvim
    use 'nvim-tree/nvim-web-devicons'    -- Optional for icon
    -- End File Explorer
  -- Begin Theme
  use { "catppuccin/nvim", as = "catppuccin" }
  -- End Theme
  -- Ending Custom Plugin
    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- ====================================
--       Begin Activate Plugins
-- ====================================

-- 1. Mempermudah untuk menambahkan penutup
-- simbol <, ", ', {, [, ( secara otomatis
require('nvim-autopairs').setup{}

-- 2. Mempermudah konfigurasi dan pengaturan
-- Language Server Protocol (LSP) untuk
-- berbagai bahasa pemrograman.
local lspconfig = require('lspconfig')



-- ====================================
--        End Activate Plugins
-- ====================================

-- ====================================
--       Begin Advanced Plugins
-- ====================================
-- Begin Autocompletion
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For using LuaSnip
    end,
  },
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item(), -- Navigasi ke item berikutnya
    ['<C-p>'] = cmp.mapping.select_prev_item(), -- Navigasi ke item sebelumnya
    ['<C-Space>'] = cmp.mapping.complete(),      -- Menampilkan menu autocompletion
    ['<C-e>'] = cmp.mapping.close(),             -- Menutup menu autocompletion
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Konfirmasi pemilihan
  },
  sources = {
    { name = 'nvim_lsp' },  -- Sumber LSP
    { name = 'buffer' },     -- Sumber buffer
    { name = 'path' },       -- Sumber path
    { name = 'luasnip' },    -- Sumber snippet
  },
})
-- End Autocompletion

-- Begin nvim Tree
require'nvim-tree'.setup {
  open_on_tab = true,
  -- Mengaktifkan fitur git integration
  git = {
    enable = true,
    ignore = false,
    timeout = 400,
  },
  -- Konfigurasi tampilan
  view = {
    width = 30,
    side = "left",
    number = false,
    relativenumber = false,
    signcolumn = "yes",
  },
  -- Fitur auto close
  actions = {
    open_file = {
      quit_on_open = false,
      window_picker = {
        enable = true,
      },
    },
  },
  -- Filter file yang tidak ingin ditampilkan
  filters = {
    dotfiles = false,
    custom = { '.git', 'node_modules', '.cache' },
    exclude = { '.gitignore' },
  },
  -- Konfigurasi renderer
  renderer = {
    add_trailing = false,
    group_empty = false,
    highlight_git = false,
    full_name = false,
    highlight_opened_files = "none",
    root_folder_modifier = ":~",
    indent_markers = {
      enable = false,
      icons = {
        corner = "└ ",
        edge = "│ ",
        item = "│ ",
        none = "  ",
      },
    },
    icons = {
      webdev_colors = true,
      git_placement = "before",
      padding = " ",
      symlink_arrow = " ➛ ",
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
      glyphs = {
        default = "",
        symlink = "",
        folder = {
          arrow_closed = "",
          arrow_open = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "★",
          deleted = "",
          ignored = "◌",
        },
      },
    },
    special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
  },
}
-- End nvim Tree

-- Theme Cappuccin
require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})


vim.cmd.colorscheme "catppuccin"
-- End Cappuccin

-- ====================================
--        End Advanced Plugins
-- ====================================

