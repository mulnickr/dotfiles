-- test keybinds
local map = require('utils').map
local opts = { noremap = true, silent = true }

-- set <leader> to <space>
vim.g.mapleader = "<space>"

-- Black formatting preference
vim.g.black_fast = 1

-- NvimTree keybinds
map('', '<leader>n', '<cmd>NvimTreeToggle<CR>', opts)
map('', '<leader>f', '<cmd>NvimTreeFocus<CR>', opts)

-- Refactoring
map({ 'n', 'v' }, '<leader>r', vim.lsp.buf.rename, opts)
map('n', '<leader>a', vim.lsp.buf.hover, opts)

-- barbar keybinds
map('n', '<A-,>', '<cmd>BufferPrevious<CR>', opts)
map('n', '<A-.>', '<cmd>BufferNext<CR>', opts)
map('n', '<a-c>', '<cmd>BufferClose<CR>', opts)

-- window splitting
map('n', '<A-n>', '<cmd>vs', opts)

--[[ LSP-specific formatting
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        vim.keymap.set('n', '<leader>F', vim.lsp.buf.format, { buffer = args.buf, silent = false })
    end
})
--]]
