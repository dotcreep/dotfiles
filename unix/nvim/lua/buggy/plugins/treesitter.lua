require('nvim-treesitter.configs').setup{
  highlight = {
    enable = true
  },
  indent = { enable = true },
  auto_install = true,
  ensure_installed = {
    'lua'
  }
}
