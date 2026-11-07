local files = require('mini.files')

-- Default setup for now
files.setup()

-- Keybinds
local map = require("utils").map
map('', '<leader>n', function() files.open() end)
