-- lua/utils.lua
local U = {}

U.ensure_installed_lsp = { "ts_ls", "cssls", "pyright", "gopls", "lua_ls" }
U.plugins = { "mason" } --, "incline", "lspconfig", "lavish", "lualine"}
U.mini_plugins = { "pick", "files", "comment", "surround", "pairs",
  "completion", "git", "notify", "statusline" }

-- Prepend github url for basic plugins
function U.gitSource(src)
  return "https://github.com/" .. src
end

-- Local vim.pack utility function
function U.packAdd(src, version, name)
  local add = {
    src = U.gitSource(src),
  }
  if version then
    add = vim.tbl_extend('force', add, version)
  end
  if name then
    add = vim.tbl_extend('force', add, name)
  end

  vim.pack.add({ add })
end

-- Multi add for simple plugins
function U.packMultiAdd(sources)
  for _, src in ipairs(sources) do
    U.packAdd(src)
  end
end

function U.ensure_packer()
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

function U.multi_load_pre(use, prefix, plugins)
  for _, plugin in ipairs(plugins) do
    use(prefix .. plugin)
  end
end

function U.multi_load(use, plugins)
  U.multi_load_pre(use, "", plugins)
end

function U.map(mode, bind, cmd, opts)
  local options = {
    noremap = true,
    silent = true
  }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, bind, cmd, options)
end

function U.info_log(msg)
  vim.notify(msg, vim.log.levels.INFO)
end

function U.message_window(msg)
  local width = 250
  local height = 5

  local buf = vim.api.nvim_create_buf(false, true)

  local opts = {
    relative = "cursor",
    width = width,
    height = height,
    bufpos = { 100, 10 },
    border = "rounded",
    title = "Logger",
    style = "minimal"
  }

  vim.api.nvim_open_win(buf, false, opts)
  vim.api.nvim_buf_set_lines(buf, 0, 0, false, { msg })

  -- close keybinds
  local keys = { "<Esc>", "<CR>" }
  for _, key in ipairs(keys) do
    vim.api.nvim_buf_set_keymap(buf, "n", key, ":lua vim.api.nvim_win_close(0, true)<CR>", {})
  end
end

function U.increase_cur_win_size(by)
  local win_count = vim.api.nvim_tabpage_list_wins(0)
  if win_count > 1 then
    local buf = vim.api.nvim_get_current_buf()
    local height = vim.api.nvim_win_get_height(buf)
    local width = vim.api.nvim_win_get_width(buf)
    vim.api.nvim_win_set_height(buf, height + by)
    vim.api.nvim_win_set_width(buf, width + by)
  end
end

function U.decrease_cur_win_size(by)
  local win_count = vim.api.nvim_tabpage_list_wins(0)
  if win_count > 1 then
    local buf = vim.api.nvim_get_current_buf()
    local height = vim.api.nvim_win_get_height(buf)
    local width = vim.api.nvim_win_get_width(buf)
    vim.api.nvim_win_set_height(buf, height - by)
    vim.api.nvim_win_set_width(buf, width - by)
  end
end

return U
