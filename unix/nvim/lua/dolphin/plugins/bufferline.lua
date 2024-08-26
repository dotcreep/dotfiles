return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
		{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
		{ "<leader>bco", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete Other Buffers" },
		{ "<leader>bcr", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
		{ "<leader>bcl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "<S-Left>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<S-Right>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
		{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
		{ "<leader>bq", [[<cmd>lua close_buffer()<CR>]], desc = "Close current tab" },
		{ "<leader>bl", "<cmd>BufferLineCycleNext<CR>", desc = "Go to next tab" },
		{ "<leader>bh", "<cmd>BufferLineCyclePrev<CR>", desc = "Go to previous tab" },
	},
	opts = {
		options = {
			-- close_command = function(n) LazyVim.ui.bufremove(n) end,
			-- right_mouse_command = function(n) LazyVim.ui.bufremove(n) end,
			always_show_bufferline = true,
			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer",
					highlight = "Directory",
					text_align = "center",
				},
			},
			show_buffer_close_icons = true,
			show_close_icon = true,
			separator_style = "thin",
			max_name_length = 18,
			max_prefix_length = 15,
			tab_size = 18,
			show_tab_indicators = true,
			enforce_regular_tabs = false,
			view = "multiwindow",
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level, diagnostics_dict, context)
				if level == "error" then
					return " "
				elseif level == "warning" then
					return " "
				elseif level == "info" then
					return " "
				elseif level == "hint" then
					return " "
				else
					return ""
				end
			end,
			diagnostics_color = {
				error = { fg = "#ff6c6b" },
				warning = { fg = "#ECBE7B" },
				info = { fg = "#0087d7" },
				hint = { fg = "#10B981" },
			},
		},
	},
	config = function(_, opts)
		require("bufferline").setup(opts)
		vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
			callback = function()
				if vim.bo.filetype == "NvimTree" then
					vim.schedule(function()
						pcall(require("bufferline").refresh)
					end)
				end
			end,
		})
		-- Fix bufferline when restoring a session
		vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
			callback = function()
				vim.schedule(function()
					pcall(nvim_bufferline)
				end)
			end,
		})
		function close_buffer()
			local buf_count = #vim.api.nvim_list_bufs()
			local current_buf = vim.api.nvim_get_current_buf()

			if buf_count > 1 then
				vim.cmd("BufferLineCyclePrev")
				vim.cmd("bd " .. current_buf)
			else
				vim.cmd("bd " .. current_buf)
			end
		end
	end,
}
