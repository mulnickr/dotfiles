return {
  name = 'cssls',
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { '.git' },
  init_options = { provideFormatter = true },
  settings = {
    css = {
      validate = true,
      -- GTK CSS (Waybar, GTK themes) uses @define-color and friends, which aren't standard CSS
      lint = { unknownAtRules = 'ignore' },
    },
  },
}
