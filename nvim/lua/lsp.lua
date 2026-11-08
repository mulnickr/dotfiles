local utils = require('utils')

---Build lsp_configs table from file names
local lsp_configs = {}
for _, f in pairs(vim.api.nvim_get_runtime_file('lua/lsp/*.lua', true)) do
  local server_name = vim.fn.fnamemodify(f, ':t:r')
  table.insert(lsp_configs, server_name)
end

---Initialize LSP configs from files
for _, l in ipairs(lsp_configs) do
  local config = require('lsp.' .. l)
  vim.lsp.config[l] = config
  vim.lsp.enable(l)
end

---Create buffer-local keybinds for an LSP-attached buffer. Called in LspAttach autocommand.
---@param bufnr integer
local key_map = function(bufnr)
  local map = utils.map

  local modes = { 'n', 'v' }
  local ext = function(o)
    return vim.tbl_extend('force', { buffer = bufnr }, o)
  end

  map(modes, '<leader>ee', vim.diagnostic.open_float, ext({ desc = 'Open Diagnostics' }))
  map(modes, '<leader>d', vim.lsp.buf.definition, ext({ desc = 'Definitions' }))
  map(modes, '<leader>A', vim.lsp.buf.implementation, ext({ desc = 'Implementation' }))
  map(modes, '<leader>a', vim.lsp.buf.hover, ext({ desc = 'Hover Information' }))

  map(modes, '<leader>K', function()
    require('internal.codeactions').run()
  end, ext({ desc = 'Code Actions' }))
  map({ 'n', 'i' }, '<C-K>', vim.lsp.buf.signature_help, ext({ desc = 'Signature Help' }))
  map(modes, '<leader>r', vim.lsp.buf.rename, ext({ desc = 'Rename' }))
  map(modes, '<leader>F', function(_)
    vim.lsp.buf.format({ async = true })
  end, ext({ desc = 'Format' }))

  map('i', '<Tab>', function(_)
    if vim.fn.pumvisible() == 1 then
      return '<C-y>'
    else
      return '<Tab>'
    end
  end, ext({ expr = true, desc = 'Autocomplete' }))
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user_lsp', { clear = true }),
  callback = function(event)
    key_map(event.buf)
    vim.lsp.completion.enable(true, event.data.client_id, event.buf, {
      noselect = true,
      menuone = true,
      autotrigger = true,
      convert = function(item)
        return { abbr = item.label:gsub('%b()', '') }
      end,
    })
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  float = {
    close_events = {
      'CursorMoved',
      'CursorMovedI',
      'BufLeave',
      'BufHidden',
      'InsertCharPre',
      'WinLeave',
      'InsertEnter',
      'LspAttach',
      'LspDetach',
    },
  },
})
