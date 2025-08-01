-- Default setup for now
require('mini.files').setup()

-- Keybinds
local map = require("utils").map
map('', '<leader>n', '<cmd>lua MiniFiles.open()<CR>', { noremap = true, silent = false })
