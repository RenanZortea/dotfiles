#!/usr/bin/env bash
# Scrollable multi-mode clock for Waybar (custom module).
#
# Usage:
#   hexclock.sh show   -> print current mode's value (used by exec)
#   hexclock.sh next   -> rotate to next mode + refresh bar (on-scroll-up)
#   hexclock.sh prev   -> rotate to prev mode + refresh bar (on-scroll-down)
#
# Modes cycle in this order. Add/remove/reorder freely:
MODES=(hexfield normal hextime unix beats)

STATE="$HOME/.config/waybar/hexclock.mode"
SIGNAL=8   # must match "signal" in the modules.json custom/hexclock block

read_idx() { [ -f "$STATE" ] && cat "$STATE" || echo 0; }

render() {
  local mode="${MODES[$1]}"
  local now secs midnight
  now=$(date +%s)
  midnight=$(date -d "today 00:00:00" +%s)
  secs=$(( now - midnight ))
  case "$mode" in
    hexfield) printf '%02X:%02X' "$(date +%-H)" "$(date +%-M)" ;;
    normal)   date '+%H:%M %a' ;;
    hextime)  printf '.%04X' "$(( secs * 65536 / 86400 ))" ;;
    unix)     date +%s ;;
    beats)    printf '@%03d' "$(( ( (now + 3600) % 86400 ) * 1000 / 86400 ))" ;;  # Swatch .beats (UTC+1)
    *)        echo "?" ;;
  esac
}

rotate() {
  local n="${#MODES[@]}" idx
  idx=$(read_idx)
  idx=$(( ( idx + $1 + n ) % n ))
  echo "$idx" > "$STATE"
  # refresh the module immediately
  pkill -RTMIN+"$SIGNAL" waybar 2>/dev/null
}

case "${1:-show}" in
  next) rotate 1 ;;
  prev) rotate -1 ;;
  show|*) render "$(read_idx)" ;;
esac
