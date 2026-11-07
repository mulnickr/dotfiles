local group = vim.api.nvim_create_augroup('user_autocmds', { clear = true })

--- Re-source plugin config files on save.
--- Patterns containing '/' are matched against the full path, hence the leading `*/`.
vim.api.nvim_create_autocmd('BufWritePost', {
  group = group,
  pattern = { '*/lua/plugins/init.lua', '*/lua/plugins/after/*.lua' },
  command = 'source <afile>',
})

--- Return to Normal mode when focus leaves the window/editor.
--- `stopinsert` only affects the mode; feeding a literal <Esc> would land in
--- whatever window gets focus next (and close floats / picker / debug views).
vim.api.nvim_create_autocmd({ 'FocusLost', 'WinLeave' }, {
  group = group,
  callback = function()
    if vim.fn.mode() == 'i' then
      vim.cmd.stopinsert()
    end
  end,
})
