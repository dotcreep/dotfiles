return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			-- See more : https://github.com/mfussenegger/nvim-lint
			-- Completelty Checking
			markdown = { "markdownlint" }, -- Linter for markdown
			python = { "flake8" }, -- Linter for Python
			go = { "golangcilint" }, -- Linter for Go
			lua = { "luacheck" }, -- Linter for LUA
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			html = { "htmlhint" },
			css = { "stylelint" },
			bash = { "shellcheck" },
			ruby = { "ruby" },
			rust = { "rstlint" },
			c = { "cpplint" },
			cpp = { "cpplint" },
			["c#"] = { "clangtidy", "trivy" },
			docker = { "hadolint", "trivy" },
			java = { "checkstyle", "trivy" },
			terraform = { "tflint", "trivy", "snyk" },
			ansible = { "ansible_lint" },
			dart = { "trivy" },
			helm = { "tflint", "trivy" },
			angular = { "eslint_d" },
			vue = { "eslint_d" },
			react = { "eslint_d" },
			yaml = { "yamllint" },
		}
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
