local utils = require("utils")
local lspconfig = require("lspconfig")
local cmp = require("cmp")
local on_attach = utils.on_attach
local info_log = utils.info_log

lspconfig["pyright"].setup({})
lspconfig["gopls"].setup({
    default_config = {
        cmd = { "gopls", "--remote=auto" },
        filetypes = { "go", "gomod" },
        root_dir = require("lspconfig.util").root_pattern("go.mod", ".git")
    },
})
lspconfig["cssmodules_ls"].setup({})

local path = "C:/Users/ramis/AppData/Roaming/npm"
--[[lspconfig["tsserver"].setup({
    cmd = { string.format("%s/tsserver", path), "--stdio" },
    root_dir = function(fname)
        return vim.loop.cwd()
    end,
})
--]]

lspconfig["html"].setup({
    cmd = { string.format("%s/html-languageserver", path), "--stdio" },
    filetypes = { "html" },
    init_options = {
        configurationSection = { "html", "css", "javascript", "typescript" },
        embeddedLanguages = {
            css = true,
            javascript = true,
            typescript = true,
        },
        provideFormatter = true
    },
    settings = {},
    single_file_support = true,
    root_dir = function(fname)
        return vim.loop.cwd()
    end,
})

--[[
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local servers = { "pyright", "tsserver", "cssls", "gopls" }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup { on_attach = on_attach, capabilities = capabilities }
end
--]]

local cmd = { "ngserver", "--stdio", "tsProbeLocations", path, "ngProbeLocations", path }
lspconfig["angularls"].setup({
    cmd = cmd,
    on_new_config = function(new_config, new_root_dir)
        new_config.cmd = cmd
    end,
    root_dir = require('lspconfig.util').root_pattern('angular.json', 'project.json')
})

local map = utils.map
local lsp_config = function(client, buf)
    
    map('n', '<leader>ee', vim.diagnostic.open_float, { buffer = buf })
    map('n', '<leader>gd', vim.lsp.buf.declaration, { buffer = buf })

    if client.server_capabilities.implementationProvider then
        map('n', '<leader>gi', vim.lsp.buf.implementation, { buffer = buf })
    end

    if client.server_capabilities.hoverProvider then
        map('n', '<leader>K', vim.lsp.buf.hover, { buffer = buf })
    end

    if client.server_capabilities.signatureHelpProvider then
        map({'n', 'i'}, '<c-k>', vim.lsp.buf.signature_help, { buffer = buf })
    end

    if client.server_capabilities.renameProvider then
        map('n', '<leader>r', vim.lsp.buf.rename, { buffer = buf })
    end

    if client.server_capabilities.formatProvider then
        map('n', '<leader>F', vim.lsp.buf.format, { buffer = buf, silent = false })
        info_log("Formatting available")
    elseif vim.bo.filetype == 'python' then
        map('n', '<leader>F', '<cmd>Black<CR>', { buffer = buf })
    else
        info_log(string.format("Formatting not supported for this file type: %s", vim.bo.filetype))
    end

end


local cmp = require('cmp')

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

-- diagnostic appearance
vim.diagnostic.config({
    virtual_text = false,
    underline = true,
    signs = true,
    float = {
        show_header = true,
        source = 'always',
        focusable = false,
    },
    update_in_insert = false,
    severity_sort = false,
})



vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        lsp_config(client, bufnr)
        info_log(string.format("%s client attached to buffer: %d", client, bufnr))
        --info_log(args.data)
    end,
})
