local utils = require("utils")


-- Replacing packer with vim.pack
--  This may require some internal setup to get working in a way I like
--
-- Basic tools
--utils.packMultiAdd({
--  'nvim-treesitter/nvim-treesitter',
--  'ferdinandrau/carbide.nvim',
--  'mini.surround',
--  'mini.statusline',
--  'mini.files',
--    'mini.comment',
--})
--require('mini.surround').setup()
--require('mini.statusline').setup()
--require('mini.files').setup()
--require('mini.pick').setup()
--require('carbide').setup('dark')

-- Lsp Setup
--utils.packMultiAdd({
--  'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim', 'neovim/nvim-lspconfig',
--})



local packer_bootstrap = require("utils").ensure_packer()

return require('packer').startup(function(use)
  -- TODO: Replacing with build in package manager (when release?)
  -- I want to replace pretty much everything here with mini.nvim
  -- Possibly even including replacing packer with mini.deps (?)

  -- general
  use {
    'nvim-treesitter/nvim-treesitter'
  }

  use {
    'williamboman/mason.nvim',
    requires = { 'williamboman/mason-lspconfig.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      require('mason').setup()
    end
  }

  use {
    'nvim-tree/nvim-web-devicons',
  }

  utils.multi_load_pre(use, "echasnovski/", {
    'mini.snippets',
    'mini.icons',
    'mini.files',
    'mini.pick',
    'mini.completion',
    'mini.statusline',
    'mini.surround',
  })

  use 'b0o/incline.nvim'

  -- color theme
  use {
    'ferdinandrau/carbide.nvim',
    config = function()
      require('carbide').setup({ 'dark' })
    end
  }

  -- use {
  --   'hrsh7th/nvim-cmp',
  --   requires = {
  --     'hrsh7th/cmp-buffer',
  --     'hrsh7th/cmp-path',
  --     'hrsh7th/cmp-nvim-lua',
  --     'hrsh7th/cmp-nvim-lsp',
  --     'hrsh7th/cmp-nvim-lsp-signature-help',
  --     'dcampos/nvim-snippy',
  --     'dcampos/cmp-snippy',
  --   }
  -- }

  if packer_bootstrap then
    require("packer").sync()
  end


  -- Setup required mini.nvim packages here?
  for _, plugin in ipairs(utils.plugins) do
    require(plugin).setup()
  end

  for _, plugin in ipairs(utils.mini_plugins) do
    require('mini.' .. plugin).setup()
  end
end)
