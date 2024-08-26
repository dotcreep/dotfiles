return {
	"j-hui/fidget.nvim",
	opts = {
		notification = {
			window = {
				winblend = 0, -- &winblend for the window
				border = "none", -- Border around the window (none, single, double, rounded, solid, shadow)
			},
			view = {
				stack_upwards = true, -- Display notification items from bottom to top
				icon_separator = " ", -- Separator between group name and icon
				group_separator = "---", -- Separator between different notification groups
				group_separator_hl = "Comment", -- Highlight group for group separator
			},
			override_vim_notify = true, -- Override the default vim.notify function with Fidget's notification system
		},

		-- Progress options
		progress = {
			poll_rate = 0, -- How frequently to poll for progress messages (in ms, default: 0 = as fast as possible)
			suppress_on_insert = false, -- Suppress new messages while in insert mode
			ignore_done_already = false, -- Ignore new tasks that are already complete
			ignore_empty_message = false, -- Ignore new tasks that don't contain a message
			clear_on_detach = function(client_id)
				return vim.tbl_contains({ "tsserver", "eslint" }, vim.lsp.get_client_by_id(client_id).name)
			end,
		},
	},
	config = function(_, opts)
		local fidget = require("fidget")
		fidget.setup(opts)
		--
		--	vim.keymap.set("n", "A", function()
		--		fidget.notify("This is from fidget.notify().")
		--	end)
		--
		--	vim.keymap.set("n", "B", function()
		--		fidget.notify("This is also from fidget.notify().", vim.log.levels.WARN)
		--	end)
		--
		--	vim.keymap.set("n", "C", function()
		--		fidget.notify("fidget.notify() supports annotations...", nil, { annote = "MY NOTE", key = "foobar" })
		--	end)
		--
		--	vim.keymap.set("n", "D", function()
		--		fidget.notify(nil, vim.log.levels.ERROR, { annote = "bottom text", key = "foobar" })
		--		fidget.notify("... and overwriting notifications.", vim.log.levels.WARN, { annote = "YOUR AD HERE" })
		--	end)
	end,
}
