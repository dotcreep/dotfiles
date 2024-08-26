return {
	"Exafunction/codeium.vim",
	event = "BufEnter",
	config = function()
		local keymap = vim.keymap
		local fn = vim.fn
		keymap.set("i", "<Tab>", function()
			return fn["codeium#Accept"]()
		end, { expr = true, silent = true })
		keymap.set("i", "<C-S-k>", function()
			return fn["codeium#CycleCompletions"](1)
		end, { expr = true, silent = true })
		keymap.set("i", "<C-S-j>", function()
			return fn["codeium#CycleCompletions"](-1)
		end, { expr = true, silent = true })
		keymap.set("i", "<C-S-c>", function()
			return fn["codeium#Clear"]()
		end, { expr = true, silent = true })
		keymap.set("n", "<leader>ici", "<cmd>CodeiumEnable<CR>", { desc = "Enable codeium" })
		keymap.set("n", "<leader>icd", "<cmd>CodeiumDisable<CR>", { desc = "Disable codeium" })
		keymap.set("n", "<leader>icm", "<cmd>CodeiumManual<CR>", { desc = "Manual codeium" })
		keymap.set("n", "<leader>ict", "<cmd>CodeiumToggle<CR>", { desc = "Toggle codeium" })
		keymap.set("n", "<leader>icb", "<cmd>CodeiumAuto<CR>", { desc = "Auto codeium" })
		keymap.set("n", "<leader>ica", "<cmd>Codeium Auth<CR>", { desc = "Auth codeium" })
	end,
}
