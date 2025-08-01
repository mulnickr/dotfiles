return {
  name = 'ts_ls',
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
  root_markers = { '.git' },
  settings = {
    ts_ls = {
      completions = {
        completeFunctionCalls = true,
      },
    },
  },
}
