require('mason').setup()

---Tools installed automatically on first start (e.g. on a fresh Linux machine).
---Names are Mason package names, not lspconfig names.
local tools = {
  -- LSP servers (see lua/lsp/*.lua)
  'gopls',
  'typescript-language-server',
  'lua-language-server',
  'css-lsp',
  'json-lsp',
  -- debug adapters (see lua/plugins/after/dap.lua)
  'delve',
  'js-debug-adapter',
}

local registry = require('mason-registry')
registry.refresh(function()
  for _, name in ipairs(tools) do
    local ok, pkg = pcall(registry.get_package, name)
    if not ok then
      vim.notify('mason: unknown package ' .. name, vim.log.levels.WARN)
    elseif not pkg:is_installed() then
      vim.notify('mason: installing ' .. name)
      pkg:install()
    end
  end
end)
