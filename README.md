# dotfiles

Configs for Windows and Linux. Each folder is linked into place by an install script,
so edits made through the normal config path land directly in this repo.

| Folder     | Windows                     | Linux                  |
| ---------- | --------------------------- | ---------------------- |
| `nvim/`    | `%LOCALAPPDATA%\nvim`       | `~/.config/nvim`       |
| `wezterm/` | `%USERPROFILE%\.config\wezterm` | `~/.config/wezterm` |
| `hypr/`    | -                           | `~/.config/hypr`       |
| `waybar/`  | -                           | `~/.config/waybar`     |
| `rofi/`    | -                           | `~/.config/rofi`       |
| `dunst/`   | -                           | `~/.config/dunst`      |
| `gtk-3.0/` | -                           | `~/.config/gtk-3.0`    |
| `bash/.bashrc` | -                       | `~/.bashrc`            |

## Install

```sh
git clone https://github.com/mulnickr/dotfiles ~/dotfiles
```

**Windows:** `powershell -ExecutionPolicy Bypass -File ~/dotfiles/install.ps1`
(directory junctions, no admin needed)

**Linux:** `~/dotfiles/install.sh` (symlinks)

Both scripts move anything already at a target to `<target>.bak-<timestamp>` instead of
deleting it, and can be re-run safely. Apps that aren't installed are skipped,
so re-run the script after installing one.

To link only some apps, name them, or skip some (names are the folder names above; `bash` for `.bashrc`):

| Want                      | Linux                          | Windows                       |
| ------------------------- | ------------------------------ | ----------------------------- |
| Only Neovim               | `install.sh nvim`              | `install.ps1 nvim`            |
| Everything except WezTerm | `install.sh --skip wezterm`    | `install.ps1 -Skip wezterm`   |
| Usage                     | `install.sh --help`            | `install.ps1 -Help`           |

Several names can be given space or comma separated. Skipped and not-installed apps are left
completely alone, including their old configs (e.g. `~/.wezterm.lua` is only moved aside when
WezTerm is linked).

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
- Google Calendar (`SUPER + D`, or clicking the Waybar clock) is set up in `hypr/conf/calendar.lua`.
  It runs Firefox with a separate profile named `gcal` so Hyprland can float just that window.
  On a new machine, create the profile once with `firefox --CreateProfile gcal` and sign in to Google there.

## Theme

Everything uses [Catppuccin Mocha](https://catppuccin.com/palette) with blue (`#89b4fa`) as the accent.
Each app keeps its own copy of the palette in its config format:
`hypr/conf/colors.lua`, `waybar/colors.css`, `rofi/catppuccin-mocha.rasi`, `dunst/dunstrc`, and
the `c` table at the top of `wezterm/wezterm.lua`.

The wallpaper is drawn by `hypr/wallpaper/generate.py`; the image itself isn't in git.
`install.sh` renders it on a new machine (needs `rsvg-convert` from `librsvg`). To change it:

```sh
cd ~/dotfiles/hypr/wallpaper
./generate.py [lake|mountains|forest] && rsvg-convert -w 3840 -h 2160 wallpaper.svg -o wallpaper.png
pkill hyprpaper; hyprpaper &
```

## Display scale

Hyprland runs at scale **1**, not a fractional scale like 1.5. At fractional scales WezTerm
sometimes sends a frame size Hyprland rejects ("Protocol error 2 on wl_surface") and every
WezTerm window closes. Fonts and spacing are set 1.5x larger in each app instead:

- WezTerm, rofi, dunst: font size 15 (WezTerm stays at 10 on Windows)
- Waybar, rofi, dunst, GTK title bars: pixel sizes x1.5
- GTK text: `gsettings set org.gnome.desktop.interface text-scaling-factor 1.5`
- Qt apps: `QT_SCALE_FACTOR=1.5` in `hypr/conf/env.lua`
- Cursor: size 24 (`hypr/conf/env.lua`, and `gsettings set org.gnome.desktop.interface cursor-size 24`)
- Firefox: set `layout.css.devPixelsPerPx` to `1.5` in `about:config` (per profile, including `gcal`)

The two `gsettings` and the Firefox setting aren't stored in this repo, so run them again on a new machine.

`SUPER + Q` starts each WezTerm window as its own process, so if one ever crashes the others stay open.
