return {
	"tzachar/cmp-tabnine",
	build = (function()
		local sysname = vim.loop.os_uname().sysname
		return sysname == "Windows_NT" and "pwsh.exe -file .\\install.ps1" or "./install.sh"
	end)(),
	dependencies = "hrsh7th/nvim-cmp",
	opts = {
		max_lines = 1000,
		max_num_results = 20,
		sort = true,
		run_on_every_keystroke = true,
		snippet_placeholder = "..",
		ignored_file_types = {
			lua = true, -- Ignore for Lua files
		},
		show_prediction_strength = false,
		min_percent = 0,
	},
	config = function(_, opts)
		require("cmp_tabnine.config"):setup(opts)
	end,
}
