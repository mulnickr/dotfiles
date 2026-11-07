local M = {}

--- Define icons for code actions
local icons = {
  [""]                           = "󰅯", -- empty kind
  ["quickfix"]                   = "󰁨", -- quick fix
  ["refactor"]                   = "󰅪", -- generic refactor
  ["refactor.extract"]           = "", -- extract to function/variable
  ["refactor.inline"]            = "", -- inline variable/function
  ["refactor.move"]              = "󰆒", -- move symbol
  ["refactor.rewrite"]           = "󰑕", -- rewrite expression
  ["source"]                     = "", -- generic source action
  ["source.fixAll"]              = "󰃢", -- fix all issues
  ["source.organizeImports"]     = "󰛢", -- organize imports
  ["source.addMissingImports"]   = "", -- add missing imports (e.g. gopls)
  ["source.removeUnusedImports"] = "󰛯", -- remove unused imports
  ["source.assembly"]            = "", -- browse assembly
  -- ["source.doc"]                 = "󰈙", -- documentation
  ["source.freesymbols"]         = "󰌷", -- free symbols
  ["source.gopls"]               = "", -- gopls feature
  ["*"]                          = "󰌵",
}

---Map an action to an icon from the `icons` table
---
---@param action table Code action
---@return string icon
local function get_icon(action)
  if not action.kind or action.kind == "" then
    return icons[""]
  end
  local kind = action.kind:lower()
  if icons[kind] then return icons[kind] end
  local prefix = kind
  while true do
    prefix = prefix:match("^(.-)%.[^%.]+$")
    if not prefix then break end
    if icons[prefix] then return icons[prefix] end
  end
  return icons["*"]
end

---Build code actions floating window
---
---@param items table List of code actions
---@param on_choice function Callback function for when an option is selected
function M.select(items, on_choice)
  local lines = {}
  local width = 0

  for i, item in ipairs(items) do
    local icon = get_icon(item.action)
    local title = item.action.title or "?"
    lines[i] = string.format("%s  %s", icon, title)
    width = math.max(width, vim.fn.strdisplaywidth(title) + 4)
  end

  width = math.min(math.max(width, 20), 80)
  local height = math.min(#lines, 15)

  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local win_height = vim.api.nvim_win_get_height(0)
  local row = (cursor_row > win_height - height - 2) and -height or 1

  local float_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  vim.bo[float_buf].modifiable = false
  vim.bo[float_buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(float_buf, true, {
    relative  = "cursor",
    row       = row,
    col       = 0,
    width     = width,
    height    = height,
    style     = "minimal",
    border    = "rounded",
    title     = " Code Actions ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true

  local closed = false
  local function close(choice)
    if closed then return end
    closed = true
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if choice then
      vim.schedule(function() on_choice(choice) end)
    end
  end

  local map = function(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { buffer = float_buf, nowait = true, silent = true })
  end

  map("<CR>", function()
    local idx = vim.api.nvim_win_get_cursor(win)[1]
    close(items[idx])
  end)
  map("q", function() close(nil) end)
  map("j", "j")
  map("k", "k")
  map("<Down>", "j")
  map("<Up>", "k")
end

---If a code action has a command, run it
---
---@param client vim.lsp.Client
---@param action table
---@param callback function
local function resolve_action(client, action, callback)
  if action.edit or action.command then
    callback(action)
    return
  end
  local cap = vim.tbl_get(client, "server_capabilities", "codeActionProvider")
  if type(cap) == "table" and cap.resolveProvider then
    client:request("codeAction/resolve", action, function(err, resolved)
      callback((err or not resolved) and action or resolved)
    end)
  else
    callback(action)
  end
end

---Apply action under cursor
---
---@param client vim.lsp.Client
---@param action table
local function apply_action(client, action)
  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding or "utf-8")
  end
  if action.command then
    local cmd = type(action.command) == "string"
        and { command = action.command, arguments = action.arguments or {} }
        or action.command
    client:request("workspace/executeCommand", cmd, function(err)
      if err then
        vim.notify("executeCommand error: " .. err.message, vim.log.levels.ERROR)
      end
    end)
  end
end

---Open code actions float
---
---@return nil
function M.run()
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.tbl_filter(function(c)
    return c:supports_method("textDocument/codeAction", bufnr)
  end, vim.lsp.get_clients({ bufnr = bufnr }))

  if #clients == 0 then
    vim.notify("No LSP client supports codeAction", vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_range_params(0, clients[1].offset_encoding)
  ---@diagnostic disable-next-line: inject-field
  params.context = {
    diagnostics = vim.diagnostic.get(bufnr, {
      lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
    }),
    triggerKind = 1,
  }

  vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(responses)
    local items = {}

    for _, response in ipairs(responses) do
      if response.result then
        local client_id = vim.tbl_get(response, "context", "client_id")
        local client = (client_id and vim.lsp.get_client_by_id(client_id)) or clients[1]
        for _, action in ipairs(response.result) do
          table.insert(items, { action = action, client = client })
        end
      end
    end

    if #items == 0 then
      vim.notify("No code actions available", vim.log.levels.INFO)
      return
    end

    if #items == 1 then
      local item = items[1]
      resolve_action(item.client, item.action, function(resolved)
        apply_action(item.client, resolved)
      end)
      return
    end

    M.select(items, function(choice)
      resolve_action(choice.client, choice.action, function(resolved)
        apply_action(choice.client, resolved)
      end)
    end)
  end)
end

return M
