local utils = require('utils')
local map = utils.map
local opts = {
  noremap = true,
  silent = true,
}

-- Navigating
map('n', '<leader>z', '<cmd>z.<CR>', opts)

-- Search/Replace
map('n', '<leader>/', '<cmd>noh<CR>', opts)

-- window splitting
map('n', '<leader>v', '<cmd>vs<CR>', opts)
map('n', '<leader>i', '<cmd>on<CR>', opts)
map({ 'n', 'v', 'i' }, '<C-h>', '<cmd>wincmd h<CR>', opts)
map({ 'n', 'v', 'i' }, '<C-j>', '<cmd>wincmd j<CR>', opts)
map({ 'n', 'v', 'i' }, '<C-k>', '<cmd>wincmd k<CR>', opts)
map({ 'n', 'v', 'i' }, '<C-l>', '<cmd>wincmd l<CR>', opts)

-- comments -- Just use gc/gcc
map('n', '<leader>c', 'gcc<CR>', opts)
map('v', '<leader>c', 'gc<CR>', opts)
