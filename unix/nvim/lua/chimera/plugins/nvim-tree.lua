return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			open_on_tab = true,
			-- Mengaktifkan fitur git integration
			git = {
				enable = true,
				ignore = false,
				timeout = 400,
			},
			-- Konfigurasi tampilan
			view = {
				width = 30,
				side = "left",
				number = false,
				relativenumber = false,
				signcolumn = "yes",
			},
			-- Fitur auto close
			actions = {
				open_file = {
					quit_on_open = false,
					window_picker = {
						enable = true,
					},
				},
			},
			-- mappings = {
			--   custom_only = true,
			--   list = {
			--     { key = {"o"}, action = "open", config = { split = "right" } },
			--   }
			-- },
			-- Filter file yang tidak ingin ditampilkan
			filters = {
				dotfiles = false,
				custom = {}, -- { '.git', 'node_modules', '.cache' },
				exclude = { ".gitignore" },
			},
			-- Konfigurasi renderer
			renderer = {
				add_trailing = false,
				group_empty = false,
				highlight_git = true,
				full_name = false,
				highlight_opened_files = "all", -- none, name, icon, all
				root_folder_modifier = ":~",
				indent_markers = {
					enable = false,
					icons = {
						corner = "└ ",
						edge = "│ ",
						item = "│ ",
						none = "  ",
					},
				},
				icons = {
					webdev_colors = true,
					git_placement = "before",
					padding = " ",
					symlink_arrow = " ➛ ",
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
					},
					glyphs = {
						default = "",
						symlink = "",
						folder = {
							---- ↆ⌞⌝◈◌
							arrow_closed = "→",
							arrow_open = "↓",
							default = "",
							open = "",
							empty = "",
							empty_open = "",
							symlink = "",
							symlink_open = "",
						},
						git = {
							unstaged = "✗",
							staged = "✓",
							unmerged = "",
							renamed = "➜",
							untracked = "★",
							deleted = "",
							ignored = "◌",
						},
					},
				},
				special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
			},
		})
	end,
}
