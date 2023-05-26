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
    use('wbthomason/packer.nvim') -- Packer
    use('christoomey/vim-tmux-navigator') -- Tmux & Split Window
    use('szw/vim-maximizer') -- Maximizer
    use('ellisonleao/gruvbox.nvim') -- Gruvbox Themes
    use('tpope/vim-surround') -- Add, delete, change surrounding (essential)
    use('vim-scripts/ReplaceWithRegister') -- Replace with register content using motion
    use('numToStr/Comment.nvim') -- Comment with gc
    use('nvim-lua/plenary.nvim') -- Lua Function
    use('nvim-tree/nvim-tree.lua') -- File Explorer
    use('kyazdani42/nvim-web-devicons') -- VSCode Icon
    use('nvim-lualine/lualine.nvim') -- Status Line
    use("hrsh7th/nvim-cmp") -- Completion plugin
    use("hrsh7th/cmp-buffer") -- Source for text in buffer
    use("hrsh7th/cmp-path") -- Source for file system
    use("L3MON4D3/LuaSnip") -- Snippet engine
    use("saadparwaiz1/cmp_luasnip") -- Autocompletion
    use("rafamadriz/friendly-snippets") -- Useful snippets
    use("jose-elias-alvarez/null-ls.nvim") -- Configure formatters & linters
    use("jayp0521/mason-null-ls.nvim") -- Bridge gap b/w
    if packer_bootstrap then
      require('packer').sync()
      vim.cmd('source '..vim.fn.stdpath('config')..'/init.lua')
    end
end)
