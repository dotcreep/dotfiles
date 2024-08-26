return {
	"ziontee113/icon-picker.nvim",
	config = function()
		require("icon-picker").setup({ disable_legacy_commands = true })

		local opts = { noremap = true, silent = true }
		local keymap = vim.keymap
		keymap.set("n", "<Leader>ui", "<cmd>IconPickerNormal<cr>", opts)
		keymap.set("n", "<Leader>uy", "<cmd>IconPickerYank<cr>", opts) --> Yank the selected icon into register
		keymap.set("i", "<C-i>", "<cmd>IconPickerInsert<cr>", opts)
	end,
}
