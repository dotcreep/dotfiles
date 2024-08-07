vim.g.mapleader = " "
local keymap = vim.keymap -- Cinciseness

-- General Keymaps -- 
keymap.set("i", "jk", "<ESC>")
keymap.set("n", "<leader>nh", ":nohl<CR>")
keymap.set("n", "x", '"_x"')
keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")

-- Window --
keymap.set("n", "<leader>sv", "<C-w>v")
keymap.set("n", "<leader>sh", "<C-w>s")
keymap.set("n", "<leader>se", "<C-w>=")
keymap.set("n", "<leader>sx", ":close<CR>")

-- Tab --
keymap.set("n", "<leader>to", ":tabnew<CR>")
keymap.set("n", "<leader>tx", ":tabclose<CR>")
keymap.set("n", "<leader>tn", ":tabn<CR>")
keymap.set("n", "<leader>tp", ":tabp<CR>")

-- Maximize --
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>")

-- Shortcut -- 
vim.api.nvim_set_keymap('n', '<F1>', ':PackerSync<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<F2>', ':NvimTreeToggle<CR>', { silent = true })
local execute_command = function()
  local filetype = vim.bo.filetype
  local command

  if filetype == 'python' then
    command = '!python %'
  elseif filetype == 'bash' then
    command = '!bash %'
  elseif filetype == 'go' then
    command = '!go run %'
  elseif filetype == 'rust' then
    command = '!cargo run -- %'
  elseif filetype == 'ruby' then
    command = '!ruby %'
  elseif filetype == 'cpp' or filetype == 'c++' then
    command = '!g++ -o %:r % && ./%:r'
  elseif filetype == 'c#' then
    command = '!dotnet run %'
  elseif filetype == 'c' then
    command = '!gcc -o %:r % && ./%:r'
  elseif filetype == 'java' then
    command = '!javac % && java %:r'
  elseif filetype == 'javascript' or filetype == 'node' then
    command = '!node %'
  elseif filetype == 'dart' or filetype == 'flutter' then
    command = '!dart %'
  elseif filetype == 'swift' then
    command = '!swift %'
  elseif filetype == 'javascriptreact' or filetype == 'typescriptreact' then
    command = '!npx react-native run-android'
  else
    print('No command for this program language')
    return
  end

  vim.cmd(command)
end

vim.api.nvim_set_keymap('n', '<F3>', ':lua execute_command()<CR>', { silent = true })

