require("auto-save").setup {
  debounce_delay = 150, -- Time autosave in ms
  enabled = true, -- Activate or nonactivate autosave
  execution_message = {
    message = function() return "Autosaved at " .. os.date("%H:%M:%S") end, -- Show message when autosaving
    dim = 0.18, -- Screen brightness on message
  },
  events = {"InsertLeave", "TextChanged"}, -- Event make autosaving
  conditions = {
    exists = true, -- Only save if file is exists
    filetype_not_in = {}, -- List of filetypes to exclude from autosave
    filetype_in = {}, -- List of filetypes allowed for autosave
  },
  write_all_buffers = true, -- Saves all modified buffers if true
}
