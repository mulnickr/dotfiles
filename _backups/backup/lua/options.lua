-- autocommand for installing & updating packer plugins when plugins.lua is saved
local packer_user_config = vim.api.nvim_create_augroup('packer_user_config', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = 'plugins.lua',
    command = 'source <afile> | PackerSync',
    group = packer_user_config,
})

-- general options
local set = vim.o

set.fileformat = unix
set.backup = false
set.swapfile = false
set.title = DEV

-- python workspace
vim.g.python3_host_prog = 'C:/Python312/python'

-- python whitespace
vim.api.nvim_command('filetype plugin indent on') -- default on?
vim.api.nvim_command('set shortmess+=c')
set.syntax = true
set.visualbell = true

set.number = true
set.relativenumber = true -- alignment?

set.tabstop = 4
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true
set.scrolloff = 10

-- python highlighting
vim.g.python_highlight_all = 1

-- autocommand group for additional syntax highlighting
local syntax_configs = vim.api.nvim_create_augroup('syntax_configs', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
    command = [[ syntax match Type /\v\.[a-zA-Z0-9_]+\ze(\[|\s|$|,|\]\)|\.|:)/hs=s+1 ]],
    group = syntax_configs,
})

vim.api.nvim_create_autocmd('BufEnter', {
    command = [[ syntax match pythonFunction /\v[[:alnum:]_]+\ze(\s?\()/ ]],
    group = syntax_configs,
})

vim.api.nvim_create_autocmd('BufEnter', {
    command = [[ syntax match Self "\(\W\|^\)@<=self\(\.\)\@=" ]],
    group = syntax_configs,
})

vim.api.nvim_command('hi def link pythonFunction function')
vim.api.nvim_command('hi def link Self Identifier')
vim.api.nvim_command('highlight Self ctermfg=130')
vim.api.nvim_command('highlight Self guifg=#ff6c6b')
vim.api.nvim_exec('highlight Self guifg=#ff6c6b', false)

-- theme
require('lualine').setup({
    options = {
        theme = 'duskfox'
        --theme = 'nordfox'
        --theme = 'nightfox'
    }
})

vim.cmd('colorscheme duskfox')
set.background = 'dark'
set.termguicolors = true

-- file handling
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

-- setup nvim-tree window resize
--require('nvim-tree').setup({
--    actions = {
--        open_file = { resize_window = true }
--    }
--})
require('bufferline').setup()


--local nvim_tree_events = require('nvim-tree.events')
local bufferline_state = require('bufferline.api')
--local nvim_tree_size = require('nvim-tree.view').View.width

--[[
nvim_tree_events.subscribe('TreeOpen', function()
    bufferline_state.set_offset(nvim_tree_size)
end)

nvim_tree_events.subscribe('Resize', function()
    bufferline_state.set_offset(nvim_tree_size)
end)

nvim_tree_events.subscribe('TreeClose', function()
    bufferline_state.set_offset(0)
end)
--]]


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
            clear_on_cursor_move = true,
        },

        highlight_current_scope = { enable = true },

        navigation = {
            enable = true,
            keymaps = {
                goto_definition = 'gnd',
                list_definitions = 'gnD',
                list_definitions_toc = 'g0',
                goto_next_usage = '<A-*>',
                goto_previous_usage = '<A-#>',
            },
        },

        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = 'gnn',
                node_incremental = 'grn',
                scope_incremental = 'grc',
                node_decremental = 'grm',
            },
        },
    },
}



