return {
  {
    "tpope/vim-fugitive",
    config = function()
      local cmd = vim.cmd
      local input = vim.fn.input
      local keymap = vim.keymap
      local api = vim.api.nvim_create_user_command
      --------------------------------
      api("GitPush", function()
        local function commit()
          local message = input("Enter commit message: ")
          return message
        end
        local message = commit()
        cmd("Git add .")
        cmd('Git commit -m "' .. message .. '"')
        cmd("Git push")
      end, { desc = "Git add, commit and push" })

      api("Newbranch", function()
        local name = input("New branch name: ")
        cmd("Git checkout -b " .. name)
      end, { desc = "Create new branch" })

      api("Delbranch", function()
        local name = input("Delete branch name: ")
        cmd("Git branch -d " .. name)
      end, { desc = "Delete branch" })

      api("Switchbranch", function()
        local name = input("Switch branch to: ")
        cmd("Git checkout " .. name)
      end, { desc = "Switch branch" })

      --- Keymaps
      keymap.set("n", "<leader>gcp", "<cmd>GitPush<CR>", { desc = "Git push in one action" })
      keymap.set("n", "<leader>gb", "<cmd>Newbranch<CR>", { desc = "Create new branch" })
      keymap.set("n", "<leader>gr", "<cmd>Delbranch<CR>", { desc = "Delete branch" })
      keymap.set("n", "<leader>gsw", "<cmd>Switchbranch<CR>", { desc = "Switch branch" })
      keymap.set("n", "<leader>gst", "<cmd>Git status<CR>", { desc = "Git status" })
      keymap.set("n", "<leader>gd", "<cmd>Git diff<CR>", { desc = "Show different in split" })
      keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
      keymap.set("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })
      keymap.set("n", "<leader>gl", "<cmd>Git pull<CR>", { desc = "Git pull" })
      keymap.set("n", "<leader>gwr", "<cmd>Gwrite<CR>", { desc = "Git write" })
      keymap.set("n", "<leader>ga", "<cmd>Git add .<CR>", { desc = "Git add all" })
    end
  },
}
