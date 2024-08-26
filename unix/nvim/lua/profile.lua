local M = {}

M.setup = function(config)
  if config.profile == 'alpha' then
    require("alpha.setup")
  elseif config.profile == 'buggy' then
    require("buggy.setup")
  elseif config.profile == 'chimera' then
    require("chimera")
  elseif config.profile == 'dolphin' then
    require('dolphin')
  end
end

return M
