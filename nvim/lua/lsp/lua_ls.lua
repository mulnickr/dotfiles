return {
  name = 'lua_ls',
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      workspace = {
        checkThirdParty = false, --- `true` prompts "configure as luv?" on every new workspace
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    },
  },
}
