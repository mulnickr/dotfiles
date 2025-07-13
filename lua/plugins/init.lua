local packer_bootstrap = require("utils").ensure_packer()

return require('packer').startup(function(use)
  -- I want to replace pretty much everything here with mini.nvim
  -- Possibly even including replacing packer with mini.deps (?)

  -- general
  use {
    'nvim-treesitter/nvim-treesitter'
  }
  -- require("utils").multi_load(use, { 'EdenEast/nightfox.nvim', -- theme
  --'nvim-treesitter/nvim-treesitter' })                       -- nvim-treesitter

  use {
    'williamboman/mason.nvim',
    requires = { 'williamboman/mason-lspconfig.nvim', 'neovim/nvim-lspconfig' }
  }

  -- color theme
  use {
    'ferdinandrau/lavish.nvim',
  }

  -- status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', {
      's1n7ax/nvim-window-picker',
      version = '2.*'
    } }
  }

  -- file search
  use {
    'Yggdroot/LeaderF',
    run = ':LeaderfInstallCExtension'
  }

  -- file handling
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    requires = { 'nvim-lua/plenary.nvim', -- plenary
      'nvim-tree/nvim-web-devicons',      -- icons
      'MunifTanjim/nui.nvim',             -- ui stuff?
      {
        's1n7ax/nvim-window-picker',
        version = '2.*'
      } }
  }

  use {
    'romgrk/barbar.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  -- autocomplete
  use {
    'windwp/nvim-autopairs',
    config = function()
      require 'nvim-autopairs'.setup()
    end
  }

  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'dcampos/nvim-snippy',
      'dcampos/cmp-snippy',
    }
  }

  if packer_bootstrap then
    require("packer").sync()
  end
end)
