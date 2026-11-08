local P = {}

---Takes a string or a table and formats it to be managed by vim.pack
---
---@param spec string | table plugin to install
---@return table spec formatted plugin spec
function P.plugin(spec)
  if type(spec) == 'string' then
    return { src = 'https://github.com/' .. spec }
  elseif type(spec) == 'table' then
    local name = spec[1]
    if not name then
      error('plugin: missing plugin name in spec: ' .. vim.inspect(spec))
    end
    local result = { src = 'https://github.com/' .. name }
    for k, v in pairs(spec) do
      if k ~= 1 then
        result[k] = v
      end
    end
    return result
  else
    error('plugin: invalid type')
  end
end

---Formats multiple plugin specs with the same prefix.
---
---Example: prefix='nvim-mini', specs={'surround', 'comment'}
---Result:  { P.plugin('nvim-mini/surround'), P.plugin('nvim-mini/comment') }
---
---@param prefix string GitHub project prefix
---@param specs table plugin specifications for each module in a project
---@return table result formatted plugin specs for vim.pack
function P.plugin_group(prefix, specs)
  local result = {}
  for _, spec in ipairs(specs) do
    if type(spec) == 'string' then
      local new = P.plugin(prefix .. spec)
      local conf = {
        config = function()
          require(spec).setup()
        end,
      }
      local tbl = vim.tbl_extend('force', new, conf)
      table.insert(result, tbl)
    elseif type(spec) == 'table' then
      if not spec[1] then
        error('plugin_group: missing plugin name: ' .. vim.inspect(spec))
      end
      local new = { prefix .. spec[1] }
      for k, v in pairs(spec) do
        if k ~= 1 then
          new[k] = v
        end
      end
      table.insert(result, P.plugin(new))
    else
      error('plugin_group: invalid type')
    end
  end
  return result
end

---Check whether a table can be treated like an array
---@param t table
---@return boolean
function P.is_array(t)
  if type(t) ~= 'table' then
    return false
  end
  local i = 1
  for k, _ in pairs(t) do
    if k ~= i then
      return false
    end
    i = i + 1
  end
  return true
end

---Flatten table into plugin spec
---
---@param t table
---@return table result
function P.flatten(t)
  local result = {}
  local function _flatten(item)
    if type(item) == 'table' and P.is_array(item) then
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

---If a plugin spec has a `config` callback function, apply it
---
---@param plugins table plugin specs
function P.init_plugins(plugins)
  for _, p in ipairs(plugins) do
    if type(p) == 'table' and type(p.config) == 'function' then
      local ok, err = pcall(p.config)
      if not ok then
        vim.notify('Plugin initialization failed (' .. p.src .. '): ' .. err, vim.log.levels.ERROR)
      end
    end
  end
end

return P
