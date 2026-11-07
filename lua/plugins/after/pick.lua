local MiniPick = require("mini.pick")

-- Default setup for now
MiniPick.setup()

-- Keybinds
local map = require("utils").map

map('n', '<leader><leader>', '<cmd>Pick files<CR>')
map('n', '<leader>g', '<cmd>Pick grep_live<CR>')
map('n', '<leader>b', '<cmd>Pick buffers<CR>')
