local plugins = require("utils").plugins

for _, plugin in ipairs(plugins) do
    require('plugins.after.' .. plugin)
end
