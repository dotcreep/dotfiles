return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")
    auto_session.setup({
      auto_session_enabled = true,
      auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_allowed_dirs = nil,
      auto_session_create_enabled = true,
      auto_session_enable_last_session = false,
      auto_session_use_git_branch = false,
      auto_restore_lazy_delay_enabled = true,
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Documents", "~/Dev", "~/Downloads", "~/Desktop" },
    })
    vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    local keymap = vim.keymap
    keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore sessions for cwd" })
    keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for autosession root dir" })
  end,
}
