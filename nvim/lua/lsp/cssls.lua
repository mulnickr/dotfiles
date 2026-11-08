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
    -- Same settings for SCSS and Less, which the server configures separately
    scss = { validate = true, lint = { unknownAtRules = 'ignore' } },
    less = { validate = true, lint = { unknownAtRules = 'ignore' } },
  },
}
