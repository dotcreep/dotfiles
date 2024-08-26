local M = {}

function M.openHelpBot()
  vim.cmd('split lua/help.md')
  vim.cmd('filetype detect')
end

function M.openHelpRight()
  vim.cmd('vsplit lua/help.md')
  vim.cmd('filetype detect')
end

function M.openVerticalSplit()
    vim.cmd('vsplit')
    vim.cmd('NvimTreeToggle')
end


function M.openHorizontalSplit()
    vim.cmd('split')
    vim.cmd('NvimTreeToggle')
end

-- Window Navigation
function M.setupKeyMaps()
  local keymap_opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap('n', '<C-M-Left>', '<C-w>h', keymap_opts)
  vim.api.nvim_set_keymap('n', '<C-M-Down>', '<C-w>j', keymap_opts)
  vim.api.nvim_set_keymap('n', '<C-M-Up>', '<C-w>k', keymap_opts)
  vim.api.nvim_set_keymap('n', '<C-M-Roght>', '<C-w>l', keymap_opts)
end

return M
