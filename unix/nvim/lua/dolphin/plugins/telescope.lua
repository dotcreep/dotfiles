return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    telescope.setup({
      defaults = {
        path_display = {
          "smart",
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          }
        }
      }
    })
    telescope.load_extension("fzf")
    local keymap = vim.keymap
    keymap.set('n', '<leader>ff', "<cmd>Telescope find_files<CR>", { desc = "Find files" })
    keymap.set('n', '<leader>fg', "<cmd>Telescope live_grep<CR>", { desc = "Live grep for text" })
    keymap.set('n', '<leader>fr', "<cmd>Telescope oldfiles<CR>", { desc = "Find recent files" })
    keymap.set('n', '<leader>fb', "<cmd>Telescope buffers<CR>", { desc = "Live open buffer" })
    keymap.set('n', '<leader>fc', "<cmd>Telescope grep_string<CR>", { desc = "Find text" })
    keymap.set('n', '<leader>fh', "<cmd>Telescope help_tags<CR>", { desc = "Find help tags" })
  end
}
