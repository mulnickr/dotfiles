local dap = require('dap')
local dv = require('dap-view')

---Path inside a Mason package directory. Debug adapters are spawned with
---libuv directly, which can't run Mason's `.cmd` shims on Windows, so point
---at the real files instead of `mason/bin`.
---@param ... string path segments below `mason/packages`
---@return string
local function mason_pkg(...)
  return vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'packages', ...)
end

---Use the Mason-installed file if present, otherwise fall back to PATH.
---@param path string
---@param fallback string
---@return string
local function prefer(path, fallback)
  return vim.uv.fs_stat(path) and path or fallback
end

local exe = vim.fn.has('win32') == 1 and '.exe' or ''

--------------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------------
dv.setup({
  -- Open when a session starts, close when the last one ends
  auto_toggle = true,
  windows = {
    terminal = {
      -- delve and osv report program output through the REPL, not a terminal
      hide = { 'go', 'nlua' },
    },
  },
  -- Inline variable values (needs nvim 0.12)
  virtual_text = { enabled = true },
})

local signs = {
  DapBreakpoint = { text = '●', texthl = 'DiagnosticError' },
  DapBreakpointCondition = { text = '◆', texthl = 'DiagnosticWarn' },
  DapLogPoint = { text = '◉', texthl = 'DiagnosticInfo' },
  DapBreakpointRejected = { text = '○', texthl = 'DiagnosticHint' },
  DapStopped = { text = '→', texthl = 'DiagnosticOk', linehl = 'Visual' },
}
for name, sign in pairs(signs) do
  vim.fn.sign_define(name, sign)
end

--------------------------------------------------------------------------------
-- Go (delve)
--------------------------------------------------------------------------------
require('dap-go').setup({
  delve = { path = prefer(mason_pkg('delve', 'dlv' .. exe), 'dlv') },
})

--------------------------------------------------------------------------------
-- JavaScript / TypeScript (vscode-js-debug)
--------------------------------------------------------------------------------
dap.adapters['pwa-node'] = {
  type = 'server',
  host = '127.0.0.1',
  port = '${port}',
  executable = {
    command = 'node',
    args = { mason_pkg('js-debug-adapter', 'js-debug', 'src', 'dapDebugServer.js'), '${port}', '127.0.0.1' },
    -- Detached processes outlive Neovim on Windows (same default as nvim-dap-go)
    detached = vim.fn.has('win32') == 0,
  },
}

local js_configs = {
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch current file (node)',
    program = '${file}',
    cwd = '${workspaceFolder}',
    sourceMaps = true,
    skipFiles = { '<node_internals>/**' },
  },
  {
    type = 'pwa-node',
    request = 'attach',
    name = 'Attach to process (node --inspect)',
    processId = require('dap.utils').pick_process,
    cwd = '${workspaceFolder}',
    sourceMaps = true,
    skipFiles = { '<node_internals>/**' },
  },
}
for _, ft in ipairs({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }) do
  dap.configurations[ft] = js_configs
end

--------------------------------------------------------------------------------
-- Lua / Neovim (one-small-step-for-vimkind)
--
-- 1. In the Neovim instance to debug:  <leader>xl  (starts the osv server)
-- 2. In a second instance: open the file, set breakpoints, <leader>xc to attach
-- 3. Trigger the code in the first instance
--------------------------------------------------------------------------------
local osv_port = 8086

dap.adapters.nlua = function(callback, config)
  callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or osv_port })
end

dap.configurations.lua = {
  { type = 'nlua', request = 'attach', name = 'Attach to running Neovim instance' },
}

--------------------------------------------------------------------------------
-- Keymaps (<leader>x = "execute")
--------------------------------------------------------------------------------
local map = require('utils').map

map('n', '<leader>xb', dap.toggle_breakpoint, { desc = 'Debug: toggle breakpoint' })
map('n', '<leader>xB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Debug: conditional breakpoint' })
map('n', '<leader>xc', dap.continue, { desc = 'Debug: start / continue' })
map('n', '<leader>xn', dap.step_over, { desc = 'Debug: step over' })
map('n', '<leader>xi', dap.step_into, { desc = 'Debug: step into' })
map('n', '<leader>xo', dap.step_out, { desc = 'Debug: step out' })
map('n', '<leader>xC', dap.run_to_cursor, { desc = 'Debug: run to cursor' })
map('n', '<leader>xr', dap.restart, { desc = 'Debug: restart' })
map('n', '<leader>xq', dap.terminate, { desc = 'Debug: terminate' })
map('n', '<leader>xv', dv.toggle, { desc = 'Debug: toggle view' })
map({ 'n', 'x' }, '<leader>xw', '<cmd>DapViewWatch<CR>', { desc = 'Debug: watch expression' })
map({ 'n', 'x' }, '<leader>xe', '<cmd>DapViewHover<CR>', { desc = 'Debug: evaluate under cursor' })
-- Global on purpose: the debuggee instance may not have a Lua buffer open
map('n', '<leader>xl', function()
  require('osv').launch({ port = osv_port })
end, { desc = 'Debug: make this Neovim debuggable (osv)' })

-- Go: debug the test under the cursor (uses the treesitter go parser)
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user_dap', { clear = true }),
  pattern = 'go',
  callback = function(ev)
    local dap_go = require('dap-go')
    map('n', '<leader>xt', dap_go.debug_test, { buffer = ev.buf, desc = 'Debug: nearest Go test' })
    map('n', '<leader>xT', dap_go.debug_last_test, { buffer = ev.buf, desc = 'Debug: last Go test' })
  end,
})
