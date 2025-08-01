local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local utils = require("utils")

local map = vim.keymap.set
local opts = {
  noremap = true,
  silent = true
}

local on_attach = function(client, bufnr)
  opts.buffer = bufnr

  -- set keybinds
  map('n', '<leader>A', vim.lsp.buf.definition, opts)
  map('n', '<leader>D', vim.lsp.buf.implementation, opts)

  local server = client.server_capabilities
  if server.implementationProvider then
    map('n', '<leader>gi', vim.lsp.buf.implementation, opts)
  end

  if server.hoverProvider then
    map('n', '<leader>a', vim.lsp.buf.hover, opts)
  end

  if server.signatureHelpProvider then
    map({ 'n', 'i' }, '<C-r>', vim.lsp.buf.signature_help, opts)
  end

  if server.renameProvider then
    map('n', '<leader>r', vim.lsp.buf.rename, opts)
  end

  -- if server.formatProvider then
  --    map('n', '<leader>F', vim.lsp.buf.format, opts)
  -- end

  local function open_float()
    vim.diagnostic.open_float({
      scope = "cursor",
      focusable = false,
      close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre", "WinLeave" }
    })
  end

  map('n', '<leader>d', open_float, opts)
end

local capabilities = cmp_nvim_lsp.default_capabilities()
for _, config in ipairs(utils.ensure_installed_lsp) do
  lspconfig[config].setup({
    capabilities = capabilities,
    on_attach = on_attach
  })
end

lspconfig['lua_ls'].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true
        }
      }
    }
  }
})

lspconfig['gopls'].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true
      }
    }
  }
})

lspconfig['html'].setup({
  init_options = {
    configurationSection = { "html", "css", "javascript", "typescript" },
    embeddedLanguages = {
      css = true,
      javascript = true,
      typescript = true
    },
    provideFormatter = true
  }
})

-- diagnostic configs
vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  signs = true,
  float = {
    show_header = true,
    source = true,
    focusable = false
  },
  update_in_insert = false,
  severity_sort = false
})

-- format command? for some reason only seems to work as an auto command
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.keymap.set('n', '<leader>F', vim.lsp.buf.format, { buffer = args.buf, silent = false })
  end
})
