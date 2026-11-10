local files = require('mini.files')

-- Default setup for now
files.setup({
  windows = {
    max_number = 2,
    width_focus = 25,
    width_nofocus = 5,

    preview = true,
    width_preview = 50,
  },
  mappings = {
    -- Swapped: `l` opens a file and closes the explorer, `L` keeps it open
    go_in = 'L',
    go_in_plus = 'l',
  },
})

-- The preview only appears when the file list and the full preview fit side by side (79 columns
-- with the widths above). Narrow the preview to whatever room is left instead, so it still shows
-- in small windows and splits. Below ~39 columns only the file list fits.
local function fit_preview()
  local room = vim.o.columns - (25 + 2) - 2 -- file list and both windows' borders
  return { windows = { width_preview = math.max(10, math.min(50, room)) } }
end

-- Keybinds
local map = require('utils').map
map('', '<leader>n', function()
  files.open(nil, true, fit_preview())
end)

-- Re-fit if the editor is resized while the explorer is open
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('MiniFilesFitPreview', {}),
  callback = function()
    if files.get_explorer_state() then
      files.refresh(fit_preview())
    end
  end,
})
