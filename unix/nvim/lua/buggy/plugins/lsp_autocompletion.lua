--- Setup LSP Server
local lsp_servers = {
  'html',
  'cssls',
  'tsserver',
  'eslint',
  'gopls',
  'lua_ls',
  'bashls',
  'pyright',
  'ltex',
  'vuels',
  'yamlls',
  'jsonls',
  'gradle_ls',
  'dockerls',
  --'jinja_lsp',
  --'ast_grep',
  'clangd',                  -- require unzip
  'arduino_language_server', -- require unzip
  'ansiblels',
  'angularls',
  'helm_ls'
}

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = lsp_servers,
}

local function setup_lsp(server)
  require("lspconfig")[server].setup{}
end

for _, server in ipairs(lsp_servers) do
  setup_lsp(server)
end

--- Autocompletions
local cmp = require('cmp')

cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-j>'] = cmp.mapping.select_next_item(), -- Navigation to next item
    ['<C-k>'] = cmp.mapping.select_prev_item(), -- Navigation to prev item
    ['<C-Down>'] = cmp.mapping.select_next_item(), -- Navigation to next item
    ['<C-Up>'] = cmp.mapping.select_prev_item(), -- Navigation to prev item
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },   -- Source LSP
    { name = 'luasnip' },    -- Source snippet
    { name = 'buffer' },     -- Source buffer
    { name = 'path' },       -- Source path
  }, {
    { name = 'buffer' },
  })
})

