local options = {
    clipboard = "unnamed,unnamedplus", --- Copy-paste between vim and everything else
    cmdheight = 0, --- Give more space for displaying messages
    completeopt = "menu,menuone,noselect", --- Better autocompletion
    cursorline = true, --- Highlight of current line
    emoji = false, --- Fix emoji display
    expandtab = true, --- Use spaces instead of tabs
    foldcolumn = "0",
    foldnestmax = 0,
    foldlevel = 99, --- Using ufo provider need a large value
    foldlevelstart = 99, --- Expand all folds by default
    ignorecase = true, --- Needed for smartcase
    laststatus = 3, --- Have a global statusline at the bottom instead of one for each window
    mouse = "a", --- Enable mouse
    number = true, --- Shows current line number
    pumheight = 10, --- Max num of items in completion menu
    relativenumber = true, --- Enables relative number
    scrolloff = 8, --- Always keep space when scrolling to bottom/top edge
    shiftwidth = 2, --- Change a number of space characters inserted for indentation
    showtabline = 2, --- Always show tabs
    signcolumn = "yes:2", --- Add extra sign column next to line number
    smartcase = true, --- Uses case in search
    smartindent = true, --- Makes indenting smart
    smarttab = true, --- Makes tabbing smarter will realize you have 2 vs 4
    softtabstop = 2, --- Insert 2 spaces for a tab
    splitright = true, --- Vertical splits will automatically be to the right
    swapfile = false, --- Swap not needed
    tabstop = 2, --- Insert 2 spaces for a tab
    termguicolors = true, --- Correct terminal colors
    timeoutlen = 200, --- Faster completion (cannot be lower than 200 because then commenting doesn't work)
    undofile = true, --- Sets undo to file
    updatetime = 100, --- Faster completion
    viminfo = "'1000", --- Increase the size of file history
    wildignore = "*node_modules/**", --- Don't search inside Node.js modules (works for gutentag)
    wrap = false, --- Display long lines as just one line
    writebackup = false, --- Not needed
    -- Neovim defaults
    autoindent = true, --- Good auto indent
    backspace = "indent,eol,start", --- Making sure backspace works
    backup = false, --- Recommended by coc
    --- Concealed text is completely hidden unless it has a custom replacement character defined (needed for dynamically showing tailwind classes)
    conceallevel = 2,
    concealcursor = "", --- Set to an empty string to expand tailwind class when on cursorline 
    encoding = "utf-8", --- The encoding displayed
    errorbells = false, --- Disables sound effect for errors
    fileencoding = "utf-8", --- The encoding written to file
    incsearch = true, --- Start searching before pressing enter
    showmode = false, --- Don't show things like -- INSERT -- anymore
    -- syntax = true,
    visualbell = true,
    background = "dark"
}

local globals = {
    mapleader = ' ',
    maplocalleader = ';',
    speeddating_no_mappings = 1,

    -- python
    python3_host_prog = 'C:/Python312/python',
    python_highlight_all = 1,

    -- file handling
    loaded = 1,
    loaded_netrwPlugin = 1
}

vim.cmd('colorscheme lavish')
vim.opt.shortmess:append('c');
vim.opt.formatoptions:remove('c');
vim.opt.formatoptions:remove('r');
vim.opt.formatoptions:remove('o');
vim.opt.fillchars:append('stl: ');
vim.opt.fillchars:append('eob: ');
vim.opt.fillchars:append('fold: ');
vim.opt.fillchars:append('foldopen: ');
vim.opt.fillchars:append('foldsep: ');
vim.opt.fillchars:append('foldclose:');

for k, v in pairs(options) do
    vim.opt[k] = v
end

for k, v in pairs(globals) do
    vim.g[k] = v
end

-- theme
require('lualine').setup({
    options = {
        theme = 'lavish'
    }
})

-- autocomplete appearance
--[[
local cmp = require('cmp')
local on_attach = require('utils').on_attach


cmp.setup {
    snippet = {
        expand = function(args)
            require('snippy').expand_snippet(args.body)
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },

    mapping = cmp.mapping.preset.insert({
        ['<S-Tab>'] = cmp.mapping.close(),
        ['<a-b>'] = cmp.mapping.scroll_docs(-4),
        ['<a-n>'] = cmp.mapping.scroll_docs(4),

        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                local entry = cmp.get_selected_entry()
                if not entry then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                end

                cmp.confirm()
            else
                fallback()
            end
        end, { "i" }),
    }),

    sources = cmp.config.sources({
        { name = 'nvim_lsp_signature_help' },
        { name = 'nvim_lua', priority = 4 },
        { name = 'nvim_lsp', priority = 1 },
        { name = 'snippy', priority = 3 },
        { name = 'path', priority = 5 },
        { name = 'buffer', priority = 2 },
    }),

    formatting = {
        format = function(entry, item)
            item.menu = ({
                nvim_lsp_signature_help = '[sig]',
                buffer = '[buf]',
                nvim_lsp = '[lsp]',
                path = '[path]',
                snippy = '[snip]',
                nvim_lua = '[lua]',
            })[entry.source.name]
            return item
        end,
    },

    experimental = {
        ghost_text = true,
    },
}
--]]

--[[
-- startup LSP for Python files
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'python',
    callback = function()
        vim.lsp.start({
            name = 'pyright',
            cmd = { 'pyright' },
            root_dir = vim.fs.dirname(vim.fs.find({ 'setup.py', 'pyproject.toml' }, { upward = true })[1]),
        })
    end,
})

-- startup LSP for Go files
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'go',
    callback = function()
        vim.lsp.start({
            name = 'gopls',
            cmd = { 'gopls' },
        })
    end,
})

-- startup LSP for TypeScript files
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'ts|tsx',
    callback = function()
        vim.lsp.start({
            name = 'tsserver',
            cmd = { 'tsserver' },
        })
    end,
})
--]]

--[[
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    --[[
    local map = require('utils').map
    map({ 'n', 'v' }, '<leader>r', vim.lsp.buf.rename, opts)
    map('n', '<leader>K', vim.lsp.buf.hover, opts)
    --]]

--[[
    if client.supports_method("textDocument/formatting") then
        -- format with lsp
        vim.keymap.set('n', '<leader>F', vim.lsp.buf.format, { buffer = args.buf, silent = false })
    elseif vim.cmd("filetype detect") == "python" then
        -- format with black
        vim.keymap.set('n', '<leader>F', "<cmd>Black<CR>", { buffer = args.buf, silent = false })
    else
        -- do nothing?
    end
end
--]]

--[[
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').pyright.setup {
    --on_attach = on_attach,
    capabilities = capabilities
}
--]]

-- refactoring
require('nvim-treesitter.configs').setup {
    refactor = {
        highlight_definitions = {
            enable = true,
            clear_on_cursor_move = true
        },

        highlight_current_scope = {
            enable = true
        },

        navigation = {
            enable = true,
            keymaps = {
                goto_definition = 'gnd',
                list_definitions = 'gnD',
                list_definitions_toc = 'g0',
                goto_next_usage = '<A-*>',
                goto_previous_usage = '<A-#>'
            }
        },

        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = 'gnn',
                node_incremental = 'grn',
                scope_incremental = 'grc',
                node_decremental = 'grm'
            }
        }
    }
}

