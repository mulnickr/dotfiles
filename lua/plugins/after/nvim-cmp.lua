local cmp = require("cmp")
local snippy = require("snippy")

cmp.setup({
  completion = {
    completeopt = "menu,menuone,preview,noselect"
  },
  snippet = {
    expand = function(args)
      snippy.expand_snippet(args.body)
    end
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    -- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<S-CR>'] = cmp.mapping.complete(),
    ['<S-Tab>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        local entry = cmp.get_selected_entry()
        if not entry then
          cmp.select_next_item({
            behavior = cmp.SelectBehavior.Select
          })
        end

        -- auto import here?
        cmp.confirm()
      else
        fallback()
      end
    end, { 'i' }),
  }),

  sources = cmp.config.sources({ {
    name = 'nvim_lsp_signature_help'
  }, {
    name = 'nvim_lsp'
  }, {
    name = 'nvim_lua'
  }, {
    name = 'snippy'
  }, {
    name = 'path'
  }, {
    name = 'buffer'
  } }),

  formatting = {
    format = function(entry, item)
      item.menu = ({
        nvim_lsp_signature_help = '[sig]',
        buffer = '[buf]',
        nvim_lsp = '[lsp]',
        path = '[path]',
        snippy = '[snip]',
        nvim_lua = '[nvim]'
      })[entry.source.name]
      return item
    end
  },

  experimental = {
    ghost_text = true
  }
})
