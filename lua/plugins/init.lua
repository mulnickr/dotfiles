local function plugin(spec)
  if type(spec) == "string" then
    return { src = "https://github.com/" .. spec }
  elseif type(spec) == "table" then
    local name = spec[1]
    if not name then
      error("plugin: missing plugin name in spec: " .. vim.inspect(spec))
    end
    local result = { src = "https://github.com/" .. name }
    for k, v in pairs(spec) do
      if k ~= 1 then
        result[k] = v
      end
    end
    return result
  else
    error("plugin: invalid type")
  end
end

local function plugin_group(prefix, specs)
  local result = {}
  for _, spec in ipairs(specs) do
    if type(spec) == "string" then
      table.insert(result, plugin(prefix .. spec))
    elseif type(spec) == "table" then
      if not spec[1] then
        error("plugin_group: missing plugin name: " .. vim.inspect(spec))
      end
      local new = { prefix .. spec[1] }
      for k, v in pairs(spec) do
        if k ~= 1 then
          new[k] = v
        end
      end
      table.insert(result, plugin(new))
    else
      error("plugin_group: invalid type")
    end
  end
  return result
end

local function is_array(t)
  if type(t) ~= "table" then return false end
  local i = 1
  for k, _ in pairs(t) do
    if k ~= i then return false end
    i = i + 1
  end
  return true
end

local function flatten(t)
  local result = {}
  local function _flatten(item)
    if type(item) == "table" and is_array(item) then
      for _, v in ipairs(item) do
        _flatten(v)
      end
    else
      table.insert(result, item)
    end
  end
  _flatten(t)
  return result
end

local function init_plugins(plugins)
  for _, p in ipairs(plugins) do
    if type(p) == "table" and type(p.config) == "function" then
      local ok, err = pcall(p.config)
      if not ok then
        vim.notify("Plugin initialization failed: " .. err, vim.log.levels.ERROR)
      end
    end
  end
end

local mini_plugins = {
  'mini.pick',
  'mini.files',
  'mini.comment',
  'mini.surround',
  'mini.pairs',
  'mini.completion',
  'mini.notify',
  'mini.statusline',
  'mini.icons',
  'mini.snippets',
}

local plugin_list = flatten({
  -- treesitter
  plugin({
    'nvim-treesitter/nvim-treesitter',
    version = 'master',
  }),

  -- general
  plugin({
    'ferdinandrau/carbide.nvim',
    config = function()
      require('carbide').setup({ 'dark' })
    end,
  }),

  -- lsp
  plugin_group('williamboman/', {
    {
      'mason.nvim',
      config = function()
        require('mason').setup()
      end,
    },
    {
      'mason-lspconfig.nvim',
      config = function()
        require('mason-lspconfig').setup()
      end,
    },
  }),
  plugin('neovim/nvim-lspconfig'),

  -- mini
  plugin_group('echasnovski/', mini_plugins)
})

vim.pack.add(plugin_list)
init_plugins(plugin_list)

-- Configure all `mini` plugins
local utils = require("utils")
for _, p in ipairs(utils.mini_plugins) do
  require('mini.' .. p).setup()
end

-- require('plugins.after.lspconfig')

-- custom mini plugins
local setup_mini = { 'comment', 'completion', 'files', 'pick', 'statusline' }
for _, m in ipairs(setup_mini) do
  require('plugins.after.mini.' .. m)
end
