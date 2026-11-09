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
  mappings = {
    -- Swapped: `l` opens a file and closes the explorer, `L` keeps it open
    go_in = 'L',
    go_in_plus = 'l',
  },
})

-- Keybinds
local map = require('utils').map
map('', '<leader>n', function()
  files.open()
end)
