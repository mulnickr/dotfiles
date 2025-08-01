local utils = require("utils")
local plugins = utils.plugins
local mini_plugins = utils.mini_plugins

for _, plugin in ipairs(plugins) do
  require('plugins.after.' .. plugin)
end

for _, mini in ipairs(mini_plugins) do
  require('plugins.after.mini.' .. mini)
end
