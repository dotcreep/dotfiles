--------------------------------------------------------
--- Variable
local map = vim.api.nvim_set_keymap
local expand = vim.fn.expand
local set = vim.keymap.set
local opts = { noremap = true, silent = true }
local api = vim.api.nvim_create_user_command
local fun = require('buggy.maps.func')
--------------------------------------------------------
--- Command
api('GitPush', function()
  fun.gitCommitPush()
end, { desc = 'Git add, commit and push' })

api('Nbranch', function()
  fun.createBranch()
end, { desc = 'Create new branch' })

api('Dbranch', function()
  fun.deleteBranch()
end, { desc = 'Delete branch' })

api('Sbranch', function()
  fun.switchBranch()
end, { desc = 'Switch branch' })

api('Setup', function()
  fun.openSetup()
end, { desc = 'Open setup in horizontal' })

api('Vsetup', function()
  fun.openvSetup()
end, { desc = 'Open setup in vertical' })

api('Rundev', function()
  fun.Rundev(expand("%"))
end, { desc = 'Run program' })

api('OpenConfig', function()
  fun.openConfig()
end, { desc = 'Open nvim config' })

api('Pip', function(opts)
  fun.pythonPip(opts.args)
end, { nargs = '+' , desc = 'Python pip'})
--------------------------------------------------------
--- KeyMaps
--- Begin Git Area
map('n', '<leader>gcp', ':GitPush<CR>', opts)
map('n', '<leader>gb', ':Nbranch<CR>', opts)
map('n', '<leader>gr', ':Dbranch()<CR>', opts)
map('n', '<leader>gw', ':Sbranch()<CR>', opts)
map('n', '<leader>gs', ':Gstatus<CR>', opts)
map('n', '<leader>gd', ':Gdiffsplit<CR>', opts)
map('n', '<leader>gc', ':Gcommit<CR>', opts)
map('n', '<leader>gp', ':Gpush<CR>', opts)
map('n', '<leader>gl', ':Gpull<CR>', opts)
--- End Git Area

--- File Explorer
map('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-- Open file setup
map('n', '<leader>sth', ':Setup<CR>', opts)
map('n', '<leader>stv', ':Vsetup<CR>', opts)

-- Open nvim config folder
map('n', '<leader>oc', ':OpenConfig<CR>', opts)

-- Running program
map('n', '<leader>r', ':Rundev<CR>', opts)

--- Open file in split mode
-- map('n', '<leader>sv', ':lua short.openVerticalSplit()<CR>', opts)
-- map('n', '<leader>sh', ':lua short.openHorizontalSplit()<CR>', opts)

--- Tab navigation
map('n', '<leader>t', ':tabnew<CR>', opts)
map('n', '<C-Space>', ':tabnew<CR>', opts)

--- Navigation
map('n', '<C-A-Left>', '<C-w>h', opts)
map('n', '<C-A-Right>', '<C-w>l', opts)
map('n', '<C-A-Up>', '<C-w>k', opts)
map('n', '<C-A-Down>', '<C-w>j', opts)

map('n', '<C-A-h>', '<C-w>h', opts)
map('n', '<C-A-l>', '<C-w>l', opts)
map('n', '<C-A-k>', '<C-w>k', opts)
map('n', '<C-A-j>', '<C-w>j', opts)

--- Resize Split Tab
map('n', '<C-h>', ':vertical resize +2<CR>', opts)
map('n', '<C-l>', ':vertical resize -2<CR>', opts)
map('n', '<C-k>', ':resize +2<CR>', opts)
map('n', '<C-j>', ':resize -2<CR>', opts)

--- Telescope
local builtin = require('telescope.builtin')

set('n', '<leader>ff', builtin.find_files, {})
set('n', '<leader>fg', builtin.live_grep, {})
set('n', '<leader>fb', builtin.buffers, {})
set('n', '<leader>fh', builtin.help_tags, {})
---
