local utils = require("utils")
local map = utils.map

map('v', '<leader>c', 'gc', { noremap = true, silent = true })
map('n', '<leader>c', 'gcc', { noremap = true, silent = true })
