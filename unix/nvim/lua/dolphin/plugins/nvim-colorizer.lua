return {
	"norcalli/nvim-colorizer.lua",
	config = function()
		require("colorizer").setup({
			"css",
			"scss",
			"javascript",
			"typescript",
			"lua",
			"vim",
			"html",
			"javascriptreact",
			"typescriptreact",
		})
	end,
}
