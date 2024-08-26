vim.g.mapleader = " "

local keymap = vim.keymap
local o = { noremap = true, silent = true }

keymap.set("n", "<leader>nh", "<cmd>nohl<CR>", { desc = "Clear search highlight" }, o)

keymap.set("n", "<leader>rt", "<cmd>source %<CR>", { desc = "Reload" }, o)

-- Basic Key
keymap.set("n", "<C-a>", "ggVG", { desc = "Select all text" }, o)
keymap.set("i", "<C-a>", "<Esc>ggVG", { desc = "Select all text" }, o)
keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save file" }, o)
keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" }, o)
keymap.set("n", "<leader>cc", ":%s///g", { desc = "Replace text" })

-- Tab Navigation
keymap.set("n", "<leader>tt", "<cmd>tabnew<CR>", { desc = "Open new tab" }, o)
keymap.set("n", "<leader>qq", "<cmd>BufferLineCyclePrev<CR><cmd>bd #<CR>", { desc = "Close current tab" }, o)
keymap.set("n", "<leader>tl", "<cmd>BufferLineCycleNext<CR>", { desc = "Go to next tab" }, o)
keymap.set("n", "<leader>th", "<cmd>BufferLineCyclePrev<CR>", { desc = "Go to previous tab" }, o)
keymap.set("n", "<leader>tt", "<cmd>tabnew %<CR>", { desc = "Open in new tab" }, o)

-- Switch Tab
keymap.set("n", "<A-Left>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Switch to left tab" }, o)
keymap.set("n", "<A-Right>", "<cmd>BufferLineCycleNext<CR>", { desc = "Switch to right tab" }, o)
keymap.set("n", "<C-PageUp>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Switch to left tab" }, o)
keymap.set("n", "<C-PageDown>", "<cmd>BufferLineCycleNext<CR>", { desc = "Switch to right tab" }, o)
keymap.set("i", "<C-PageUp>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Switch to left tab" }, o)
keymap.set("i", "<C-PageDown>", "<cmd>BufferLineCycleNext<CR>", { desc = "Switch to right tab" }, o)

-- Window Management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertical" }, o)
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontal" }, o)
-- keymap.set('n', '<leader>se', '<C-w>=', { desc = 'Make split equal size' }, o)
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }, o)
keymap.set("n", "<C-h>", "<cmd>vertical resize +2<CR>", { desc = "Resize window" }, o)
keymap.set("n", "<C-l>", "<cmd>vertical resize -2<CR>", { desc = "Resize window" }, o)
keymap.set("n", "<C-k>", "<cmd>resize +2<CR>", { desc = "Resize window" }, o)
keymap.set("n", "<C-j>", "<cmd>resize -2<CR>", { desc = "Resize window" }, o)

-- Switch Window
keymap.set("n", "<C-A-Left>", "<C-w>h", { desc = "Switch window to left" }, o)
keymap.set("n", "<C-A-Right>", "<C-w>l", { desc = "Switch window to right" }, o)
keymap.set("n", "<C-A-Up>", "<C-w>k", { desc = "Switch winoow to above" }, o)
keymap.set("n", "<C-A-Down>", "<C-w>j", { desc = "Switch window to below" }, o)
keymap.set("n", "<C-A-h>", "<C-w>h", { desc = "Switch window to left" }, o)
keymap.set("n", "<C-A-l>", "<C-w>l", { desc = "Switch window to right" }, o)
keymap.set("n", "<C-A-k>", "<C-w>k", { desc = "Switch window to above" }, o)
keymap.set("n", "<C-A-j>", "<C-w>j", { desc = "Switch window to below" }, o)

-- File Explorer
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" }, o)

--- Resize Split Tab
keymap.set("n", "<C-h>", "<cmd>vertical resize +2<CR>", { desc = "Increase size vertical split window" }, o)
keymap.set("n", "<C-l>", "<cmd>vertical resize -2<CR>", { desc = "Decrease size vertical split window" }, o)
keymap.set("n", "<C-k>", "<cmd>resize +2<CR>", { desc = "Increase size horizontal split window" }, o)
keymap.set("n", "<C-j>", "<cmd>resize -2<CR>", { desc = "Decrease size horizontal split window" }, o)

--- Open Terminal
keymap.set("n", "<leader>tv", "<cmd>OpenTerminalVertical<CR>", { desc = "Open terminal in vertical" }, o)
keymap.set("n", "<leader>ts", "<cmd>OpenTerminal<CR>", { desc = "Open terminal in horizontal" }, o)
keymap.set("n", "<leader>te", "<cmd>ToggleTerm<CR>", { desc = "Open terminal" }, o)

------------------------------------------------------------------------
