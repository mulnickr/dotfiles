# Neovim config

Requires Neovim 0.12+ (uses the built-in `vim.pack` plugin manager and `vim.lsp.config`).

## Locations

| Config  | Windows                             | Linux                                  |
| ------- | ----------------------------------- | -------------------------------------- |
| Neovim  | `%LOCALAPPDATA%\nvim\init.lua`      | `~/.config/nvim/init.lua`              |
| LazyGit | `%LOCALAPPDATA%\lazygit\config.yml` | `~/.config/lazygit/config.yml`         |
| WezTerm | `%USERPROFILE%\.wezterm.lua`        | `~/.config/wezterm/wezterm.lua`        |

WezTerm uses the first config it finds: `$WEZTERM_CONFIG_FILE`, then
`$XDG_CONFIG_HOME/wezterm/wezterm.lua` (`~/.config/wezterm/` by default), then `~/.wezterm.lua`.
The location can differ per machine, so check `$WEZTERM_CONFIG_FILE` when in doubt.

Plugin data (plugins, Mason tools, treesitter parsers) lives in `stdpath('data')`:
`%LOCALAPPDATA%\nvim-data` on Windows, `~/.local/share/nvim` on Linux.

## New machine setup

1. Install system prerequisites:
   - `git`, `ripgrep` (`Pick grep_live`), a Nerd Font in the terminal
   - `tree-sitter` CLI 0.25+ and a C compiler (`gcc`/`clang`) for treesitter parsers
   - `go` (gopls, delve) and `node` 22.18+ (TypeScript language server, js-debug; runs `.ts` directly)
   - Linux clipboard: `wl-clipboard` (Wayland) or `xclip` (X11); on WSL, `win32yank`
2. Clone this repo to the config location above.
3. Start `nvim`. `vim.pack` installs plugins at the revisions in `nvim-pack-lock.json`,
   Mason installs LSP servers and debug adapters (`lua/plugins/after/mason.lua`), and
   nvim-treesitter compiles parsers (`lua/plugins/after/treesitter.lua`). Restart once it finishes.
4. Run `:checkhealth` if anything looks off.

Update plugins with `:lua vim.pack.update()`, then commit `nvim-pack-lock.json`.

## Debugging

nvim-dap with the nvim-dap-view UI (opens when a session starts and closes when it ends).
nvim-dap also reads `.vscode/launch.json` from the project root when it exists.

| Key           | Action                                |
| ------------- | ------------------------------------- |
| `<leader>xc`  | start / continue                      |
| `<leader>xb`  | toggle breakpoint                     |
| `<leader>xB`  | conditional breakpoint                |
| `<leader>xn`  | step over                             |
| `<leader>xi`  | step into                             |
| `<leader>xo`  | step out                              |
| `<leader>xC`  | run to cursor                         |
| `<leader>xr`  | restart                               |
| `<leader>xq`  | terminate                             |
| `<leader>xv`  | toggle dap-view                       |
| `<leader>xw`  | watch word / selection                |
| `<leader>xe`  | evaluate word / selection (hover)     |
| `<leader>xt`  | Go: debug nearest test                |
| `<leader>xT`  | Go: debug last test                   |
| `<leader>xl`  | Lua: make this Neovim debuggable (osv)|

Inside dap-view, switch views with the winbar letters (`W`, `S`, `B`, `T`, `R`, ...) and use `g?` for help.

**Lua / Neovim:** in the instance you want to debug, press `<leader>xl`. In a second instance,
open the file, set breakpoints and press `<leader>xc` to attach. Then trigger the code in the first instance.
