local M = {}
local name = require('buggy.settings.namespace').namespace

M.setup = function(config)
  if config.themes == 'catppuccin' then
    require(name .. '.themes.catppuccin')
  end
  if config.themes == 'gruvbox' then
    require(name .. '.themes.gruvbox')
  end
  if config.themes == 'vscode' then
    require(name .. '.themes.vscode')
  end
end

return M
