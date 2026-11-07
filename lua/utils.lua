local U = {}

---Key map with `silent = true` by default (`vim.keymap.set` is already noremap)
---
---@param mode string | table insert(i), normal(n), visual(v), etc.
---@param bind string keybind ex: `<leader>c`
---@param cmd string | function command to be called on key press
---@param opts? table
function U.map(mode, bind, cmd, opts)
  vim.keymap.set(mode, bind, cmd, vim.tbl_extend('force', { silent = true }, opts or {}))
end

return U
