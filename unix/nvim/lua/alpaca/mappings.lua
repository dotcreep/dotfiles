local short = require('alpha.shortcut')
local lsp_install = require('alpha.lsp_installer')

-- Use ':S1' for install plugin
vim.api.nvim_create_user_command('S1', function()
  vim.cmd('PackerInstall')
end, {})

-- Use
vim.api.nvim_create_user_command('Helpbot', function()
  short.openHelpBot()
end, { desc = 'Open help.md in a vertical split'})

-- Use
vim.api.nvim_create_user_command('Helpright', function()
  short.openHelpRight()
end, { desc = 'Open help.md in a horizon split'})

-- Use 
vim.api.nvim_create_user_command('LSP', function()
  local lang = opts.args
  lsp_install.install_language_server(lang)
end, {})

---
--- KeyMaps
---
-- Install Autocompletion
vim.api.nvim_set_keymap('n', '<leader>lspts', ':LSP typescript<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>lsppy', ':LSP python<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>lsprs', ':LSP rust<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>lspgo', ':LSP go<CR>', { noremap = true, silent = true })

-- File Explorer
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Open File in split
vim.api.nvim_set_keymap('n', '<leader>sv', ':lua short.openVerticalSplit()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sh', ':lua short.openHorizontalSplit()<CR>', { noremap = true, silent = true })

-- Open Help Documents
vim.api.nvim_set_keymap('n', '<leader>h', ':Helpright<CR>', { noremap = true, silent = true })

-- Tab Navigation
vim.api.nvim_set_keymap('n', '<leader>t', ':tabnew<CR>', { noremap = true, silent = true })
