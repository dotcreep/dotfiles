return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup {
      size = 12,                -- Terminal size
      open_mapping = [[<c-\>]], -- Open terminal
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = 'horizontal', -- 'horizontal', 'vertical', 'tab', 'float'
    }
    local keymap = vim.keymap
    function _G.set_terminal_keymaps()
      keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = "Exit insert mode" })
      keymap.set('t', '<C-q>', [[<C-\><C-n>]], { desc = "Exit insert mode" })
    end

    vim.api.nvim_create_user_command("Term", function()
      require("toggleterm.terminal").Terminal:new({ cmd = "bash", hidden = true }):toggle()
    end, {})
    vim.cmd('autocmd! TermOpen * lua set_terminal_keymaps()')
  end
}
