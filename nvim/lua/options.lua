local options = {
  clipboard = 'unnamed,unnamedplus',     --- Copy-paste between vim and everything else
  cmdheight = 0,                         --- Give more space for displaying messages
  completeopt = 'menu,menuone,noinsert', --- Better autocompletion
  cursorline = true,                     --- Highlight of current line
  emoji = false,                         --- Fix emoji display
  expandtab = true,                      --- Use spaces instead of tabs
  foldcolumn = '0',
  -- foldnestmax = 0,
  foldlevel = 99,                  --- Using ufo provider need a large value
  foldlevelstart = 99,             --- Expand all folds by default
  foldmethod = 'expr',             --- Fold method
  foldexpr = 'v:lua.vim.treesitter.foldexpr()',
  ignorecase = true,               --- Needed for smartcase
  laststatus = 3,                  --- Have a global statusline at the bottom instead of one for each window
  mouse = 'a',                     --- Enable mouse
  number = true,                   --- Shows current line number
  pumheight = 10,                  --- Max num of items in completion menu
  relativenumber = true,           --- Enables relative number
  scrolloff = 8,                   --- Always keep space when scrolling to bottom/top edge
  shiftwidth = 2,                  --- Change a number of space characters inserted for indentation
  showtabline = 0,                 -- 2, --- Always show tabs
  signcolumn = 'yes:2',            --- Add extra sign column next to line number
  smartcase = true,                --- Uses case in search
  smartindent = true,              --- Makes indenting smart
  smarttab = true,                 --- Makes tabbing smarter will realize you have 2 vs 4
  softtabstop = 2,                 --- Insert 2 spaces for a tab
  splitright = true,               --- Vertical splits will automatically be to the right
  swapfile = false,                --- Swap not needed
  tabstop = 2,                     --- Insert 2 spaces for a tab
  termguicolors = true,            --- Correct terminal colors
  timeoutlen = 200,                --- Faster completion (cannot be lower than 200 because then commenting doesn't work)
  undofile = true,                 --- Sets undo to file
  updatetime = 100,                --- Faster completion
  viminfo = "'1000",               --- Increase the size of file history
  wildignore = '*node_modules/**', --- Don't search inside Node.js modules (works for gutentag)
  wrap = false,                    --- Display long lines as just one line
  writebackup = false,             --- Not needed
  -- Neovim defaults
  autoindent = true,               --- Good auto indent
  backspace = 'indent,eol,start',  --- Making sure backspace works
  backup = false,                  --- Recommended by coc
  --- Concealed text is completely hidden unless it has a custom replacement character defined (needed for dynamically showing tailwind classes)
  conceallevel = 2,
  concealcursor = '',     --- Set to an empty string to expand tailwind class when on cursorline
  encoding = 'utf-8',     --- The encoding displayed
  errorbells = false,     --- Disables sound effect for errors
  fileencoding = 'utf-8', --- The encoding written to file
  incsearch = true,       --- Start searching before pressing enter
  showmode = false,       --- Don't show things like -- INSERT -- anymore
  -- syntax = true,
  visualbell = true,
  background = 'dark',
}

local is_windows = vim.fn.has('win32') == 1

local globals = {
  mapleader = ' ',
  maplocalleader = ';',

  -- file handling (mini.files replaces netrw)
  loaded_netrw = 1,
  loaded_netrwPlugin = 1,
}

-- Python provider: on Windows `python3` is usually the Microsoft Store stub,
-- so prefer `python`. Elsewhere Neovim finds `python3` on its own.
if is_windows and vim.fn.executable('python') == 1 then
  globals.python3_host_prog = vim.fn.exepath('python')
end

vim.opt.shortmess:append('c')
vim.opt.formatoptions:remove('c')
vim.opt.formatoptions:remove('r')
vim.opt.formatoptions:remove('o')
vim.opt.fillchars:append('stl: ')
vim.opt.fillchars:append('eob: ')
vim.opt.fillchars:append('fold: ')
vim.opt.fillchars:append('foldopen: ')
vim.opt.fillchars:append('foldsep: ')
vim.opt.fillchars:append('foldclose:')

for k, v in pairs(options) do
  vim.opt[k] = v
end

for k, v in pairs(globals) do
  vim.g[k] = v
end
