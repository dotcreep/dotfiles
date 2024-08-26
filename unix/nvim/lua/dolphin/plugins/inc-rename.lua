return {
  "smjonas/inc-rename.nvim",
  config = function()
    require("inc_rename").setup({})
    local keymap = vim.keymap
    keymap.set("n", "<leader>rn", ":IncRename", { desc = "Rename string (text)" })
  end,
}
