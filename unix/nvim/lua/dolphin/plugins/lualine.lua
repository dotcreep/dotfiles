return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local function progress_bar()
			local current_line = vim.fn.line(".")
			local total_lines = vim.fn.line("$")
			local chars = { "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥" }
			-- { "·", "∘", "○", "◯" }
			-- { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
			local line_ratio = current_line / total_lines
			local index = math.ceil(line_ratio * #chars)
			return chars[index]
		end
		local function tabnine_status()
			local ok, tabnine = pcall(require, "tabnine.status")
			if not ok then
				return "󰋙 AI"
			end
			local status = tabnine.status()
			if status:find("starter") then
				return "󰋘 AI"
			elseif status:find("pro") then
				return "󰐭 AI"
			elseif status:find("loading") then
				return "󱗿 AI"
			else
				return "󰋙 AI"
			end
		end

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				section_separators = { left = "", right = "" },
				-- section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = false,
				globalstatus = true,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = {
					function()
						local mode = vim.fn.mode()
						if mode == "n" then
							return ""
						-- return '🅝 NORMAL'
						elseif mode == "i" then
							return ""
						-- return '🅘 INSERT'
						elseif mode == "v" then
							return ""
						-- return '🅥 VISUAL'
						elseif mode == "V" then
							return ""
						-- return '🅥 VISUAL-LINE'
						elseif mode == "R" then
							return ""
						-- return '🅡 REPLACE'
						elseif mode == "c" then
							return ""
						-- return '🅒 COMMAND'
						elseif mode == "t" then
							return ""
						else
							return "󰺕"
						end
					end,
				},
				lualine_b = {
					"branch",
					{
						"diff",
						symbols = {
							added = " ",
							modified = "柳",
							removed = " ",
						},
						diff_color = {
							added = {
								fg = "#2da44e",
							},
							modified = {
								fg = "#e16f24",
							},
							removed = {
								fg = "#fa4549",
							},
						},
					},
				},
				lualine_c = {
					{
						"diagnostics",
						symbols = {
							error = " ", -- Ikon untuk kesalahan
							warn = " ", -- Ikon untuk peringatan
							info = " ", -- Ikon untuk informasi
							hint = " ", -- Ikon untuk petunjuk
						},
					},
					{ "lsp_progress" },
					{
						"filename",
						fmt = function(filename)
							local name_without_ext = vim.fn.fnamemodify(filename, ":t:r")
							local devicons = require("nvim-web-devicons")
							local icon = devicons.get_icon(name_without_ext, "", { default = false })
							if not icon then
								local ext = vim.fn.expand("%:e")
								icon = devicons.get_icon(ext, "", { default = true })
							end
							if not icon then
								icon = require("nvim-web-devicons").get_icon("", "", { default = true })
							end
							return "%=" .. (icon or " ") .. " " .. filename
						end,
						path = 1,
					},
				},
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = {
					function()
						local location = "%l•%v"
						return progress_bar() .. " " .. location
					end,
				},
				lualine_z = {
					-- { tabnine_status },
					{
						function()
							local status = vim.api.nvim_call_function("codeium#GetStatusString", {})
							return "󰚩" .. status
						end,
						cond = function()
							return vim.fn.exists("*codeium#GetStatusString") == 1
						end,
						-- color = { fg = "#ffcc00" }, -- Change color as needed
					},
					-- {
					-- 	function()
					-- 		return "" .. " " .. os.date("%H:%M")
					-- 	end,
					-- },
				},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		})
	end,
}
