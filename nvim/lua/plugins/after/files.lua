local files = require('mini.files')

-- Default setup for now
files.setup({
  windows = {
    max_number = 2,
    width_focus = 25,
    width_nofocus = 5,

    preview = true,
    width_preview = 50,
  },
})

-- Keybinds
local map = require('utils').map
map('', '<leader>n', function()
  files.open()
end)
