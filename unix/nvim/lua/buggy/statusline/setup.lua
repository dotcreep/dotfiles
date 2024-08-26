local M = {}
local name = require('buggy.settings.namespace').namespace

M.setup = function(config)
  if config.statusline == 'lualine' then
    require(name .. '.statusline.lualine')
  end
  if config.statusline == 'feline' then
    require(name .. '.statusline.feline')
  end
end

return M
