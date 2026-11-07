local map = require('utils').map

--- Navigating
map('n', '<leader>z', '<cmd>z.<CR>')

--- Search/Replace
map('n', '<leader>/', '<cmd>noh<CR>')

--- window splitting
map('n', '<leader>v', '<cmd>vs<CR>')
map('n', '<leader>i', '<cmd>on<CR>')
map({ 'n', 'v', 'i' }, '<C-h>', '<cmd>wincmd h<CR>')
map({ 'n', 'v', 'i' }, '<C-j>', '<cmd>wincmd j<CR>')
map({ 'n', 'v', 'i' }, '<C-k>', '<cmd>wincmd k<CR>')
map({ 'n', 'v', 'i' }, '<C-l>', '<cmd>wincmd l<CR>')
