-- nvim-treesitter `main` branch: the plugin only installs parsers/queries.
-- Highlighting is started by Neovim itself via `vim.treesitter.start()`.
-- Requires the `tree-sitter` CLI (0.25+) and a C compiler on PATH.

-- lua, vim, vimdoc, markdown, query and c parsers ship with Neovim.
local parsers = {
  'go',
  'gomod',
  'gowork',
  'gosum',
  'javascript',
  'typescript',
  'tsx',
  'jsdoc',
  'json',
  'luadoc',
}

local ts = require('nvim-treesitter')
local missing = vim.tbl_filter(function(p)
  return not vim.list_contains(ts.get_installed(), p)
end, parsers)

if #missing > 0 then
  if vim.fn.executable('tree-sitter') == 1 then
    -- Runs asynchronously; highlighting starts for new buffers once done
    ts.install(missing)
  else
    -- Without the CLI every parser build fails with its own error, so warn once instead
    vim.notify(
      'treesitter: install the tree-sitter CLI (0.25+) and restart to build: ' .. table.concat(missing, ', '),
      vim.log.levels.WARN
    )
  end
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
  callback = function(ev)
    -- Fails quietly for filetypes without an installed parser.
    pcall(vim.treesitter.start, ev.buf)
  end,
})
