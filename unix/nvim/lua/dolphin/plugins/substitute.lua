return {
  "gbprod/substitute.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local substitute = require("substitute")
    substitute.setup()

    local keymap = vim.keymap
    keymap.set("n", "s", substitute.operator, { desc = "Subtitute with motion" })
    keymap.set("n", "ss", substitute.line, { desc = "Subtitule line" })
    keymap.set("n", "S", substitute.eol, { desc = "Subtitute to endline" })
    keymap.set("x", "s", substitute.visual, { desc = "Subtitute in visual mode" })
  end,
}
