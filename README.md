# dotfiles

Configs for Windows and Linux. Each folder is linked into place by an install script,
so edits made through the normal config path land directly in this repo.

| Folder     | Windows                     | Linux                  |
| ---------- | --------------------------- | ---------------------- |
| `nvim/`    | `%LOCALAPPDATA%\nvim`       | `~/.config/nvim`       |
| `wezterm/` | `%USERPROFILE%\.config\wezterm` | `~/.config/wezterm` |
| `hypr/`    | -                           | `~/.config/hypr`       |

## Install

```sh
git clone https://github.com/mulnickr/dotfiles ~/dotfiles
```

**Windows:** `powershell -ExecutionPolicy Bypass -File ~/dotfiles/install.ps1`
(directory junctions, no admin needed)

**Linux:** `~/dotfiles/install.sh` (symlinks)

Both scripts move anything already at a target to `<target>.bak-<timestamp>` instead of
deleting it, and can be re-run safely.

## Adding a config

1. Copy the existing folder into the repo, e.g. `cp -r ~/.config/hypr ~/dotfiles/hypr`
2. Add it to `install.sh` and/or `install.ps1` if it isn't listed yet
3. Re-run the install script; it backs up the original and links the repo copy
4. Commit

## Notes

- WezTerm uses the first config it finds: `$WEZTERM_CONFIG_FILE`, then
  `$XDG_CONFIG_HOME/wezterm/wezterm.lua` (`~/.config/wezterm/` by default), then `~/.wezterm.lua`.
  WezTerm sets `WEZTERM_CONFIG_FILE` in the shells it launches, pointing at whichever file it loaded.
- Neovim setup and prerequisites: [nvim/README.md](nvim/README.md)
