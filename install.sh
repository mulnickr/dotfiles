#!/usr/bin/env sh
# Symlink config folders from this repo into place on Linux.
#
#   ./install.sh
#
# Anything already at a target is renamed to <target>.bak-<timestamp>; nothing is deleted.
# Safe to re-run: targets that already point at this repo are left alone.
# Apps that aren't installed (no matching command on PATH) are skipped.
set -eu

repo=$(cd "$(dirname "$0")" && pwd)
stamp=$(date +%Y%m%d-%H%M%S)
config=${XDG_CONFIG_HOME:-$HOME/.config}

installed() {
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 && return 0
  done
  return 1
}

# link <repo folder> <target> <command>...  (linked if any of the commands exist)
link() {
  src="$repo/$1"
  dst="$2"
  shift 2
  [ -e "$src" ] || return 0
  if ! installed "$@"; then
    echo "skip    $dst ($1 not installed)"
    return 0
  fi

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok      $dst"
    return 0
  fi
  backup=""
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup="$dst.bak-$stamp"
    mv "$dst" "$backup"
    echo "  backed up $dst -> $backup"
  fi

  mkdir -p "$(dirname "$dst")"
  if ! ln -s "$src" "$dst"; then
    # Put the original back rather than leaving nothing in place
    [ -n "$backup" ] && mv "$backup" "$dst" && echo "  restored $dst"
    exit 1
  fi
  echo "linked  $dst -> $src"
}

link nvim    "$config/nvim"    nvim
link wezterm "$config/wezterm" wezterm
link hypr    "$config/hypr"    Hyprland hyprland
link waybar  "$config/waybar"  waybar
link rofi    "$config/rofi"    rofi
link dunst   "$config/dunst"   dunst
link gtk-3.0 "$config/gtk-3.0" gtk-launch
link bash/.bashrc "$HOME/.bashrc" bash

# ~/.config/wezterm/wezterm.lua takes precedence, so an old ~/.wezterm.lua is dead weight
if [ -e "$repo/wezterm" ] && installed wezterm && [ -e "$HOME/.wezterm.lua" ]; then
  mv "$HOME/.wezterm.lua" "$HOME/.wezterm.lua.bak-$stamp"
  echo "  backed up $HOME/.wezterm.lua -> $HOME/.wezterm.lua.bak-$stamp"
  echo "  restart open WezTerm windows: they still watch the old file and will show a config error"
fi

# Render the wallpaper from its generator if it isn't there yet (the image isn't kept in git)
wall="$repo/hypr/wallpaper"
if installed Hyprland hyprland && [ -e "$wall/generate.py" ] && [ ! -e "$wall/wallpaper.png" ]; then
  if installed python3 rsvg-convert; then
    python3 "$wall/generate.py" >/dev/null &&
      rsvg-convert -w 3840 -h 2160 "$wall/wallpaper.svg" -o "$wall/wallpaper.png" &&
      echo "rendered $wall/wallpaper.png"
  else
    echo "skip    wallpaper (needs python3 and rsvg-convert from librsvg)"
  fi
fi
