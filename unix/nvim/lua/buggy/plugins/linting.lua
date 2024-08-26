local lint = require('lint')

lint.linters_by_ft = {
  markdown = {'vale'},        -- Linter for markdown
  python = {'flake8'},        -- Linter for Python
  go = {'golangci-lint'},     -- Linter for Go
  lua = {'luacheck'},         -- Linter for LUA
}


vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require('lint').try_lint()
  end,
})
