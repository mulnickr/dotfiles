local utils = require("utils")

-- Reload packer when the plugins file is updated --
local packer_group = vim.api.nvim_create_augroup("packer_user_config", {
    clear = true
})
vim.api.nvim_create_autocmd({'BufWritePost'}, {
    pattern = 'plugins/init.lua',
    command = 'source <afile> | PackerCompile | PackerSync',
    group = packer_group
})

-- FocusLost --
local focus_group = vim.api.nvim_create_augroup("focus_group", {
    clear = true
})

-- Escape to Normal mode
vim.api.nvim_create_autocmd({"FocusLost", "BufLeave", "WinLeave"}, {
    pattern = "*",
    callback = function()
        local keys = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(keys, 'm', false)
    end,
    group = focus_group
})

-- Enter/Leave window commands
function HandleEnter()
    vim.cmd("setlocal relativenumber")
    -- utils.increase_cur_win_size(25)
end

function HandleExit()
    vim.cmd("setlocal norelativenumber")
    -- utils.decrease_cur_win_size(25)
end

vim.api.nvim_create_autocmd({"FocusLost", "InsertEnter", "BufLeave", "WinLeave"}, {
    pattern = "*",
    -- command = "setlocal norelativenumber",
    callback = HandleExit,
    group = focus_group
})

vim.api.nvim_create_autocmd({"FocusGained", "InsertLeave", "BufEnter", "WinEnter"}, {
    pattern = "*",
    -- command = "setlocal relativenumber",
    callback = HandleEnter,
    group = focus_group
})

-- Python Stuff --
-- autocommand group for additional syntax highlighting
local syntax_configs = vim.api.nvim_create_augroup('syntax_configs', {
    clear = true
})
vim.api.nvim_create_autocmd('BufEnter', {
    command = [[ syntax match Type /\v\.[a-zA-Z-1-9_]+\ze(\[|\s|$|,|\]\)|\.|:)/hs=s+1 ]],
    group = syntax_configs
})

vim.api.nvim_create_autocmd('BufEnter', {
    command = [[ syntax match pythonFunction /\v[[:alnum:]_]+\ze(\s?\()/ ]],
    group = syntax_configs
})

vim.api.nvim_create_autocmd('BufEnter', {
    command = [[ syntax match Self "\(\W\|^\)@<=self\(\.\)\@=" ]],
    group = syntax_configs
})

vim.api.nvim_command('hi def link pythonFunction function')
vim.api.nvim_command('hi def link Self Identifier')
vim.api.nvim_command('highlight Self ctermfg=130')
vim.api.nvim_command('highlight Self guifg=#ff6c6b')
vim.api.nvim_command('highlight Self guifg=#ff6c6b')

