local pack = require('plugins.utils')

---Config callback that (re)loads `lua/plugins/after/<name>.lua`.
---Clearing the module cache lets the reload-on-save autocmd pick up changes.
---@param name string
---@return function
local function after(name)
  return function()
    local mod = 'plugins.after.' .. name
    package.loaded[mod] = nil
    require(mod)
  end
end

---Plugins from mini.nvim. Strings get a default `setup()`; tables carry their own config.
local mini_plugins = {
  'mini.notify',
  { 'mini.pick',      config = after('pick') },
  { 'mini.files',      config = after('files') },
  { 'mini.statusline', config = after('statusline') },
  'mini.surround',
  'mini.pairs',
  'mini.snippets',
}

---Plugins formatted with internal `plugins.utils` methods to increase readability
local plugin_list = pack.flatten({
  -- general
  pack.plugin({
    'ferdinandrau/carbide.nvim',
    config = function()
      require('carbide').setup({ 'dark' })
      vim.cmd.colorscheme('carbide-dark')
    end,
  }),
  pack.plugin('nvim-tree/nvim-web-devicons'),

  -- mini (notify first so later plugins' messages use it)
  pack.plugin_group('nvim-mini/', mini_plugins),

  -- treesitter
  pack.plugin({ 'nvim-treesitter/nvim-treesitter', version = 'main', config = after('treesitter') }),

  -- tooling (LSP servers, debug adapters)
  pack.plugin({ 'williamboman/mason.nvim', version = 'v2.2.1', config = after('mason') }),

  -- debugging
  pack.plugin({ 'mfussenegger/nvim-dap', config = after('dap') }),
  pack.plugin({ 'igorlfs/nvim-dap-view', version = vim.version.range('1.*') }),
  pack.plugin('leoluz/nvim-dap-go'),
  pack.plugin('jbyuki/one-small-step-for-vimkind'),
})

for i, p in ipairs(plugin_list) do
  if not p.src then
    error("Broken plugin at index " .. i .. ": " .. vim.inspect(p) .. vim.inspect(plugin_list))
  end
end

vim.pack.add(plugin_list)
pack.init_plugins(plugin_list)
