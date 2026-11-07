-- Default setup for now
require('mini.files').setup()

-- Keybinds
local map = require("utils").map
map('', '<leader>n', function() MiniFiles.open() end)
