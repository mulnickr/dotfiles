#!/usr/bin/env sh
# Symlink config folders from this repo into place on Linux.
#
#   ./install.sh
#
# Anything already at a target is renamed to <target>.bak-<timestamp>; nothing is deleted.
# Safe to re-run: targets that already point at this repo are left alone.
# Folders missing from the repo (e.g. hypr/ on a fresh clone) are skipped.
set -eu

repo=$(cd "$(dirname "$0")" && pwd)
stamp=$(date +%Y%m%d-%H%M%S)
config=${XDG_CONFIG_HOME:-$HOME/.config}

link() {
  src="$repo/$1"
  dst="$2"
  [ -e "$src" ] || return 0

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

link nvim    "$config/nvim"
link wezterm "$config/wezterm"
link hypr    "$config/hypr"

# ~/.config/wezterm/wezterm.lua takes precedence, so an old ~/.wezterm.lua is dead weight
if [ -e "$repo/wezterm" ] && [ -e "$HOME/.wezterm.lua" ]; then
  mv "$HOME/.wezterm.lua" "$HOME/.wezterm.lua.bak-$stamp"
  echo "  backed up $HOME/.wezterm.lua -> $HOME/.wezterm.lua.bak-$stamp"
fi
