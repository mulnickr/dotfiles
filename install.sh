#!/usr/bin/env sh
# Symlink config folders from this repo into place on Linux.
#
#   ./install.sh                     link everything that's installed
#   ./install.sh nvim                link only these apps (space or comma separated)
#   ./install.sh --skip wezterm      link everything except these (repeatable, commas ok)
#
# Apps: nvim wezterm hypr waybar rofi dunst gtk-3.0 bash
#
# Anything already at a target is renamed to <target>.bak-<timestamp>; nothing is deleted.
# Safe to re-run: targets that already point at this repo are left alone.
# Apps that aren't installed (no matching command on PATH) are skipped.
set -eu

repo=$(cd "$(dirname "$0")" && pwd)
stamp=$(date +%Y%m%d-%H%M%S)
config=${XDG_CONFIG_HOME:-$HOME/.config}
apps="nvim wezterm hypr waybar rofi dunst gtk-3.0 bash"

# Prints the comment block at the top of this file
usage() { awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "$0"; }
die() { echo "$*" >&2; echo "Run $0 --help for usage." >&2; exit 2; }

only=""
skip=""
while [ $# -gt 0 ]; do
  case "$1" in
  -h | --help) usage && exit 0 ;;
  --skip)
    [ $# -ge 2 ] || die "--skip needs an app name"
    skip="$skip $(echo "$2" | tr ',' ' ')"
    shift 2
    ;;
  --skip=*)
    skip="$skip $(echo "${1#--skip=}" | tr ',' ' ')"
    shift
    ;;
  -*) die "unknown option: $1" ;;
  *)
    only="$only $(echo "$1" | tr ',' ' ')"
    shift
    ;;
  esac
done
for a in $only $skip; do
  case " $apps " in
  *" $a "*) ;;
  *) die "unknown app: $a (choose from: $apps)" ;;
  esac
done

# selected <app>: picked on the command line (or nothing picked) and not skipped
selected() {
  case " $skip " in *" $1 "*) return 1 ;; esac
  [ -z "$only" ] && return 0
  case " $only " in *" $1 "*) return 0 ;; esac
  return 1
}

installed() {
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 && return 0
  done
  return 1
}

# link <app> <repo path> <target> <command>...
# Linked if the app is selected and any of the commands exist.
link() {
  app="$1"
  src="$repo/$2"
  dst="$3"
  shift 3
  [ -e "$src" ] || return 0
  if ! selected "$app"; then
    echo "skip    $dst (not selected)"
    return 0
  fi
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

link nvim nvim "$config/nvim" nvim
link wezterm wezterm "$config/wezterm" wezterm
link hypr hypr "$config/hypr" Hyprland hyprland
link waybar waybar "$config/waybar" waybar
link rofi rofi "$config/rofi" rofi
link dunst dunst "$config/dunst" dunst
link gtk-3.0 gtk-3.0 "$config/gtk-3.0" gtk-launch
link bash bash/.bashrc "$HOME/.bashrc" bash

# ~/.config/wezterm/wezterm.lua takes precedence, so an old ~/.wezterm.lua is dead weight
if [ -e "$repo/wezterm" ] && selected wezterm && installed wezterm && [ -e "$HOME/.wezterm.lua" ]; then
  mv "$HOME/.wezterm.lua" "$HOME/.wezterm.lua.bak-$stamp"
  echo "  backed up $HOME/.wezterm.lua -> $HOME/.wezterm.lua.bak-$stamp"
  echo "  restart open WezTerm windows: they still watch the old file and will show a config error"
fi

# Render the wallpaper from its generator if it isn't there yet (the image isn't kept in git)
wall="$repo/hypr/wallpaper"
if selected hypr && installed Hyprland hyprland && [ -e "$wall/generate.py" ] && [ ! -e "$wall/wallpaper.png" ]; then
  if installed python3 rsvg-convert; then
    python3 "$wall/generate.py" >/dev/null &&
      rsvg-convert -w 3840 -h 2160 "$wall/wallpaper.svg" -o "$wall/wallpaper.png" &&
      echo "rendered $wall/wallpaper.png"
  else
    echo "skip    wallpaper (needs python3 and rsvg-convert from librsvg)"
  fi
fi
