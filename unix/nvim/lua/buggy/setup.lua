local name = require("buggy.settings.namespace").namespace

require(name .. '.settings.plugins')
require(name .. '.settings.basic')
require(name .. '.settings.customs')
require(name .. '.maps.setup')

local plugin = require(name .. '.plugins.setup')
local themes = require(name .. '.themes.setup')
local status = require(name .. '.statusline.setup')

plugin.setup({
  autopairs = true,
  filemanager = true,
  lsp_autocompletion = true,
  indentblackline = true,
  autosave = true,
  golang = true,
  treesitter = true,
  bufferline = true,
})

themes.setup({
  -- catppuccin or vscode or gruvbox
  themes = 'gruvbox',
})

status.setup({
  -- 'lualine', 'feline'
  statusline = 'feline',
})
