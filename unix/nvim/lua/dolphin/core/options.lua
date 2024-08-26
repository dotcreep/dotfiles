local global_options = {
  mapleader = " ",
  maplocalleader = "\\"
}

local options = {
  number = true,                 -- Show number line
  relativenumber = true,         -- Show relative number line
  expandtab = true,              -- Use space instead of tab (true)
  shiftwidth = 2,                -- Indent when using '>'
  tabstop = 2,                   -- Tab using 2 indent
  smartindent = true,            -- Smart auto indent
  autoindent = true,             -- Apply indentation before line
  cursorline = true,             -- Activated highlight line
  signcolumn = 'yes',            -- Always show sign column
  colorcolumn = '80',            -- Pinning column 80 (limited line)
  termguicolors = true,          -- Activated true color
  ignorecase = true,             -- Ignore case when searching
  smartcase = true,              -- Searcing case-sensitive if using capital
  incsearch = true,              -- Highlight matching searches while typing
  hlsearch = true,               -- Highlighting all result of searching
  wrap = false,                  -- Disable line wrapping
  scrolloff = 8,                 -- Minimum line distance from top/bot of screen
  sidescrolloff = 8,             -- Minimum line distance from sides of screen
  splitbelow = true,             -- Horizontal split below active window
  splitright = true,             -- Vertival split to the right of active window
  hidden = true,                 -- Allow unsaved buffers to remain open
  showtabline = 2,               -- Always show bar tab
  laststatus = 4,                -- Always show status bar
  cmdheight = 1,                 -- Height line command
  showmode = false,              -- Hide default statusline
  updatetime = 300,              -- Waiting update time in ms
  timeoutlen = 500,              -- Waiting time to wait for sequence mapping
  swapfile = false,              -- Does not using swap file, change true for backup
  backup = true,                 -- Does not create backup file, change true for backup
  backupdir = './.vim/backup//', -- For save data backup
  undofile = true,               -- Activated saving undo
  clipboard = 'unnamedplus',     -- Use system clipboard
  mouse = 'a',                   -- Activate mouse to using in all mode
  background = 'dark',           -- Theme 'dark' or 'light'
  -- guifont = ''                 -- Font for graphical neovim application
}

for k, v in pairs(global_options) do
  vim.g[k] = v
end

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd([[autocmd FileType python setlocal tabstop=2 shiftwidth=2 expandtab]])
