-- nvim-treesitter `main` branch: the plugin only installs parsers/queries.
-- Highlighting is started by Neovim itself via `vim.treesitter.start()`.
-- Requires the `tree-sitter` CLI (0.25+) and a C compiler on PATH.

-- lua, vim, vimdoc, markdown, query and c parsers ship with Neovim.
local parsers = {
  'go', 'gomod', 'gowork', 'gosum',
  'javascript', 'typescript', 'tsx', 'jsdoc', 'json',
  'luadoc',
}

-- No-op for parsers that are already installed; runs asynchronously otherwise.
require('nvim-treesitter').install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
  callback = function(ev)
    -- Fails quietly for filetypes without an installed parser.
    pcall(vim.treesitter.start, ev.buf)
  end,
})
