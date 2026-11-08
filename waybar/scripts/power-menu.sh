#!/bin/bash
# A true vertical dropdown menu using Rofi
CHOSEN=$(printf "   Logout\n   Restart\n   Shutdown" | rofi -dmenu -i -p "Power Menu" -theme-str 'window { width: 200px; } listview { lines: 4; }')

case "$CHOSEN" in
    *Log*) hyprctl dispatch exit ;;
    *Restart) loginctl reboot ;;
    *Shutdown) loginctl poweroff ;;
esac

