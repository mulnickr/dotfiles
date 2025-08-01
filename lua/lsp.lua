local utils = require("utils")

local lsp_configs = {}
for _, f in pairs(vim.api.nvim_get_runtime_file('lua/lsp/*.lua', true)) do
  local server_name = vim.fn.fnamemodify(f, ":t:r")
  table.insert(lsp_configs, server_name)
end

for _, l in ipairs(lsp_configs) do
  local config = require('lsp.' .. l)
  vim.lsp.config[l] = config
  vim.lsp.enable(l)
end


local key_map = function()
  local map = utils.map
  local opts = { noremap = true, silent = false }

  local modes = { 'n', 'v' }
  local ext = function(rhs)
    return vim.deepcopy(vim.tbl_extend('force', opts, rhs))
  end

  map(modes, '<leader>ee', vim.diagnostic.open_float, ext({ desc = "Open Diagnostics" }))
  map(modes, '<leader>d', vim.lsp.buf.definition, ext({ desc = "Definitions" }))
  map(modes, '<leader>A', vim.lsp.buf.implementation, ext({ desc = "Implementation" }))
  map(modes, '<leader>a', vim.lsp.buf.hover, ext({ desc = "Hover Information" }))
  map({ 'n', 'i' }, '<c-k>', vim.lsp.buf.signature_help, opts)
  map(modes, '<leader>r', vim.lsp.buf.rename, opts)
  map(modes, '<leader>F', function()
    vim.lsp.buf.format({ async = true })
  end, opts)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    vim.notify(string.format("Attaching to LSP..."))
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    key_map()
    vim.lsp.completion.enable(true, event.data.client_id, event.buf, {})
    vim.notify(string.format("%s client attached to buffer: %d", client, event.buf))
  end
})
