local utils = require('utils')
local map = utils.map
local opts = {
  noremap = true,
  silent = false
}

-- NeoTree keybinds
map('', '<leader>n', '<cmd>Neotree toggle<CR>', opts)
map('', '<leader>f', '<cmd>Neotree focus<CR>', opts)

-- Leaderf
map('n', '<leader><leader>', '<cmd>Leaderf file --popup<CR>', opts)

-- Navigating
map('n', '<leader>z', '<cmd>z.<CR>', opts)

-- Search/Replace
map('n', '<leader>/', '<cmd>noh<CR>', opts)

-- barbar keybinds
map('n', '<A-,>', '<cmd>BufferPrevious<CR>', opts)
map('n', '<A-.>', '<cmd>BufferNext<CR>', opts)
map('n', '<a-c>', '<cmd>BufferClose<CR>', opts)

-- window splitting
map('n', '<leader>v', '<cmd>vs<CR>', opts)
map('n', '<leader>i', '<cmd>on<CR>', opts)
map({ 'n', 'v', 'i' }, '<C-h>', '<cmd>wincmd h<CR>', opts)
map({ 'n', 'v', 'i' }, '<C-j>', '<cmd>wincmd j<CR>', opts)
map({ 'n', 'v', 'i' }, '<C-k>', '<cmd>wincmd k<CR>', opts)
map({ 'n', 'v', 'i' }, '<C-l>', '<cmd>wincmd l<CR>', opts)

-- comments
local comment = function()
  local buf = vim.api.nvim_get_current_buf()
  -- local mode = vim.fn.mode()
  local start = vim.fn.getpos("'<'")[1]
  local _end = vim.fn.getpos("'>'")[1]
  if vim.api.nvim_get_mode() == "n" then
    _end = start + 1
  end

  local lines = vim.api.nvim_buf_get_lines(buf, start, _end, false)
  local replace = {}
  for i, line in ipairs(lines) do
    replace[i] = string.format(vim.o.cms, line)
  end
  vim.api.nvim_buf_set_lines(buf, start, _end, false, replace)

  utils.message_window(string.format("Selected: %s -- Replace: %s", lines[0], replace[0]))

  -- local format = "Mode: %s, Start: %s, End: %s, Buffer: %s, cms: %s"
  -- local log = string.format(format, mode, start, _end, buf, vim.o.cms)
  -- utils.message_window(log)
end

map({ 'n', 'v' }, '<leader>c', comment, opts)
