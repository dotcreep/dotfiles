return {
  "diepm/vim-rest-console",
  config = function()
    local g = vim.g
    g.vrc_set_default_mapping = 0
    g.vrc_response_default_content_type = 'application/json'
    g.vrc_output_buffer_name = "_output.json"
    g.vrc_auto_format_response_patterns = {
      json = 'jq',
    }
    local keymap = vim.keymap
    keymap.set("n", "<leader>ra", "<cmd>call VrcQuery()<CR>", { desc = "Run REST Api query" })
  end,
}
