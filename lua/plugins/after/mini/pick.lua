local MiniPick = require("mini.pick")

-- Default setup for now
MiniPick.setup()

-- Keybinds
local map = require("utils").map
local opts = { noremap = false, silent = true }

map('n', '<leader><leader>', '<cmd>Pick files<CR>', opts)
map('n', '<leader>g', '<cmd>Pick grep_live<CR>', opts)
map('n', '<leader>b', '<cmd>Pick buffers<CR>', opts)
