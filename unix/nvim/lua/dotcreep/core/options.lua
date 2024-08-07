local opt = vim.opt -- Conciseness

opt.relativenumber = true -- Make number is relative
opt.number = true -- Show line number
opt.tabstop = 2 -- Tab width
opt.shiftwidth = 2 -- Tab width using space
opt.expandtab = true -- Expand Tab
opt.autoindent = true -- Indentation Automatically
opt.wrap = false -- Line Wrapping
opt.ignorecase = true -- Ignore Case
opt.smartcase = true -- Smart Search Case
opt.cursorline = false -- Cursor Line
opt.termguicolors = true -- Make color on termgui
opt.background = "dark" -- Dark color of background
opt.signcolumn = "yes" -- Sign Column
opt.backspace = "indent,eol,start" -- Backspace
opt.clipboard:append("unnamedplus") -- Clipboard
opt.splitright = true -- Split Window Right
opt.splitbelow = true -- Split Window Below
opt.iskeyword:append("-")
