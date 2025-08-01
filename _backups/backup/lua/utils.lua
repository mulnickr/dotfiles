-- lua/utils.lua

local M = {}

function M.map(mode, bind, cmd, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.keymap.set(mode, bind, cmd, options)
end

-- function M.on_attach(client, bufnr)
--     vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
--
--     local bufopts = { noremap = true, silent = true, buffer = bufnr }
--
--     -- default 'normal' mode keymaps for lsp options. rename and select variable(??)
--     vim.keymap.set('n', '<leader>K', vim.lsp.buf.hover, bufopts)
--     vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
-- end

function M.info_log(msg)
    vim.notify(msg, vim.log.levels.INFO)
end

return M
