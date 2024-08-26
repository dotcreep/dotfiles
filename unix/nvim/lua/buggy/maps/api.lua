local cmdApi = vim.api.nvim_create_user_command


cmdApi('S1', function()
  vim.cmd('PackerInstall')
end, { desc = 'Install new package'})

cmdApi('S0', function()
  vim.cmd('PackerSync')
end, { desc = 'Sync plugins package' })

-- cmdApi('Helpbot', function()
--   short.openHelpBot()
-- end, { desc = 'Open help.md in a vertical split'})
-- 
-- cmdApi('Helpright', function()
--   short.openHelpRight()
-- end, { desc = 'Open help.md in a horizon split'})
