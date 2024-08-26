return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      lua = { "luacheck", },
      python = { "pylint", "flake8", "trivy" },
      javascript = { "eslint", "trivy" },
      typescript = { "eslint", "trivy" },
      html = { "htmlhint", },
      css = { "stylelint", },
      markdown = { "vale", "markdownlint", "markdownlint-cli2", "proselint" },
      bash = { "shellcheck", "shellharden" },
      ruby = { "rubocop" },
      go = { "golangci-lint", "trivy", },
      rust = { "bacon", "trivy" },
      c = { "cpplint" },
      cpp = { "cpplint" },
      ["c#"] = { "trivy", },
      docker = { "hadolint", "trivy", "snyk" },
      java = { "checkstyle", "trivy" },
      terraform = { "tflint", "trivy", "snyk" },
      ansible = { "ansible-lint" },
      dart = { "dcm", "trivy" },
      helm = { "snyk", "trivy" },
      angular = { "eslint" },
      vue = { "eslint" },
      react = { "eslint" },
      -- Use the "*" filetype to run linters on all filetypes.
      -- ['*'] = { 'global linter' },
      -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
      -- ['_'] = { 'fallback linter' },
      -- ["*"] = { "typos" },
    }
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end
    })
    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
