#!/usr/bin/env bash
# Wi-Fi picker for the Waybar network module: lists nearby networks in rofi and connects with
# nmcli, asking for a password only when the network is secured and not saved yet.
set -u

notify() { notify-send -a "Wi-Fi" "$@"; }

if [ "$(nmcli radio wifi)" = "disabled" ]; then
  choice=$(printf '󰖩  Turn Wi-Fi on\n󰒓  Edit connections' | rofi -dmenu -i -p "Wi-Fi" -theme-str 'listview { lines: 2; }')
  case "$choice" in
  *"Turn Wi-Fi on") nmcli radio wifi on && notify "Wi-Fi on" ;;
  *"Edit connections") nm-connection-editor & ;;
  esac
  exit 0
fi

# One line per network name (strongest access point wins), connected network first
ssids=()
labels=()
while IFS=: read -r inuse signal security ssid; do
  [ -z "$ssid" ] && continue
  for s in "${ssids[@]}"; do [ "$s" = "$ssid" ] && continue 2; done
  if [ "$signal" -ge 75 ]; then
    icon="󰤨"
  elif [ "$signal" -ge 50 ]; then
    icon="󰤥"
  elif [ "$signal" -ge 25 ]; then
    icon="󰤢"
  else
    icon="󰤟"
  fi
  lock=""
  [ -n "$security" ] && [ "$security" != "--" ] && lock="  󰌾"
  mark=""
  [ "$inuse" = "*" ] && mark="  (connected)"
  ssids+=("$ssid")
  labels+=("$icon  $ssid$lock$mark")
done < <(nmcli -t -e no -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan auto | sort -t: -k1,1r -k2,2nr)

extra=("󰖪  Turn Wi-Fi off" "󰒓  Edit connections")
idx=$(printf '%s\n' "${labels[@]}" "${extra[@]}" | rofi -dmenu -i -p "Wi-Fi" -format i \
  -theme-str "listview { lines: $((${#labels[@]} + 2 < 10 ? ${#labels[@]} + 2 : 10)); }")
[ -z "$idx" ] && exit 0

n=${#ssids[@]}
if [ "$idx" -eq "$n" ]; then
  nmcli radio wifi off && notify "Wi-Fi off"
  exit 0
fi
if [ "$idx" -eq $((n + 1)) ]; then
  nm-connection-editor &
  exit 0
fi

ssid=${ssids[$idx]}
if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
  # Saved network: just bring it up
  out=$(nmcli connection up id "$ssid" 2>&1)
elif [[ ${labels[$idx]} == *"󰌾"* ]]; then
  pass=$(rofi -dmenu -password -p "Password for $ssid" -theme-str 'listview { lines: 0; }')
  [ -z "$pass" ] && exit 0
  out=$(nmcli device wifi connect "$ssid" password "$pass" 2>&1)
else
  out=$(nmcli device wifi connect "$ssid" 2>&1)
fi

if [ $? -eq 0 ]; then notify "Connected to $ssid"; else notify -u critical "Couldn't connect to $ssid" "$out"; fi
