local M = {}

local function package(command)
	return vim.fn.executable(command) == 1
end

local arch = vim.loop.os_uname().machine
local is_arm64 = arch == "aarch64" or arch == "arm64"

local not_support_arm64 = { -- Daftar tools yang tidak mendukung arm64
	clangd = true,
	harper_ls = true,
	graphql = true,
	glint = true,
	hyprls = true,
	texlab = true,
	helm_ls = true,
	lua_ls = true,
	luau_lsp = true,
	vale_ls = true,
	ols = true,
	ruby_lsp = true,
	vhdl_ls = true,
	lemminx = true,
	rust_analyzer = true,
}

local function add(t, package_name, lsp, linter, dap, formatter)
	if not package(package_name) then
		return
	end

	local function insert_if_supported(list, item)
		if item and (not is_arm64 or not not_support_arm64[item]) then
			table.insert(list, item)
		end
	end

	if is_arm64 then
		insert_if_supported(t.lsp, lsp)
		insert_if_supported(t.linter, linter)
		insert_if_supported(t.dap, dap)
		insert_if_supported(t.formatter, formatter)
	else
		if lsp then
			table.insert(t.lsp, lsp)
		end
		if linter then
			table.insert(t.linter, linter)
		end
		if dap then
			table.insert(t.dap, dap)
		end
		if formatter then
			table.insert(t.formatter, formatter)
		end
	end
end

local tools = { lsp = {}, linter = {}, dap = {}, formatter = {} }

local configurations = { -- Konfigurasi untuk berbagai bahasa dan tools
	{ "python3", "pyright", "flake8", "debugpy", "black" }, -- Python
	{ "node", "tsserver", "eslint", "node-debug2-adapter", "prettier" }, -- Node.js / Javascript
	{ "go", "gopls", "golangci_lint_ls", "delve", "gofmt" }, -- Golang
	{ "luac", "lua_ls", "luacheck", "nlua", "stylua" }, -- Lua
	{ "gcc", "clangd", "cpplint", "cpptools", "clang-format" }, -- C
	{ "g++", "clangd", "cpplint", "cpptools", "clang-format" }, -- C++
	{ "dotnet", "omnisharp", nil, nil, nil }, -- C#
	{ "node", nil, "stylelint", nil, "prettier" }, -- CSS
	{ "node", nil, "htmlhint", nil, "prettier" }, -- HTML
	{ "ruby", "solargraph", "rubocop", nil, "rufo" }, -- Ruby
	{ "rustc", "rust_analyzer", "trivy", nil, "rusttywind" }, -- Rust
	{ "r", "r_language_server", "lintr", nil, "formatR" }, -- R
	{ "node", "remark_ls", "vale", nil, "remark_cli" }, -- Markdown
	{ "bash", "bashls", "shellcheck", nil, "shfmt" }, -- Bash
	{ "arduino-cli", "arduino_language_server", nil, nil, nil }, -- Arduino
	{ "az", "azure_pipelines_ls", nil, nil, nil }, -- Azure Pipeline
	{ "cmake", "cmake", nil, nil, nil }, -- CMake
	{ "dart", "dcm", "dcm", "dart-debug-adapter", "dcm" }, -- Dart
	{ "docker", "dockerls", "hadolint", nil, nil }, -- Docker
	{ "python3", "jinja_lsp", "flake8", nil, "black" }, -- Django
	{ "gradle", "gradle_ls", nil, nil, nil }, -- Gradle
	{ "helm", "helm_ls", nil, nil, nil }, -- Helm
	{ "java", "jdtls", "checkstyle", "jdtls", "google-java-format" }, -- Java
	{ "node", nil, "jsonlint", nil, "prettier" }, -- JSON
	{ "java", "kotlin-language-server", "ktlint", nil, "ktfmt" }, -- Kotlin
	{ "perl", "perlnavigator", nil, "perl-debug-adapter", nil }, -- Perl
	{ "php", "intelephense", "phpcs", nil, "phpcs" }, -- PHP
	{ "pwsh", "powershelle", "pylint", nil, nil }, -- PowerShell
	{ "puppet", "puppet", "puppet-lint", nil, nil }, -- Puppet
	{ "sqlcmd", "sqlls", "sqlfluff", nil, nil }, -- SQL
	{ "terraform", "terraformls", "tflint", nil, nil }, -- Terraform
	{ "node", "tsserver", "eslint", nil, "prettier" }, -- TypeScript
	{ "node", "tsserver", "eslint", nil, "prettier" }, -- React
	{ "node", "volar", "eslint", nil, "prettier" }, -- Vue.js
	{ "node", "angularls", "eslint", nil, "prettier" }, -- AngularJS
	{ "vim", "vimls", nil, nil, nil }, -- Vimscript
	{ "node", nil, "yamlls", nil, "prettier" }, -- YAML
}

local function configure_tools()
	for _, config in ipairs(configurations) do
		add(tools, unpack(config))
	end
end

local function unique(t)
	local seen, result = {}, {}
	for _, v in ipairs(t) do
		if v and not seen[v] then
			seen[v] = true
			table.insert(result, v)
		end
	end
	return result
end

local cached_lsp, cached_all_tools

function M.get_tools()
	if cached_lsp and cached_all_tools then
		return cached_lsp, cached_all_tools
	end

	configure_tools()
	cached_lsp = unique(tools.lsp)
	cached_all_tools = unique(vim.tbl_flatten({ tools.linter, tools.dap, tools.formatter }))
	return cached_lsp, cached_all_tools
end

return M
