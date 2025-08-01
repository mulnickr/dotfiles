return {
  name = 'gopls',
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork" },
  root_markers = { ".git", "go.sum", "go.work" },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
}
