#!/bin/bash
#   ____ _ _       _     _     _
#  / ___| (_)_ __ | |__ (_)___| |_
# | |   | | | '_ \| '_ \| / __| __|
# | |___| | | |_) | | | | \__ \ |_
#  \____|_|_| .__/|_| |_|_|___/\__|
#           |_|
#
# Point to your custom Tech/Glass theme
THEME="$HOME/.config/rofi/launchers/type-4/style-1.rasi"

case $1 in
d)
    # Delete specific item
    cliphist list | rofi -dmenu -replace -theme "$THEME" -p "❌ Delete Copy" | cliphist delete
    ;;

w)
    # Wipe everything
    if [ $(echo -e "Clear\nCancel" | rofi -dmenu -theme "$THEME" -p "⚠️ Wipe All?") == "Clear" ]; then
        cliphist wipe
    fi
    ;;

*)
    # Standard Paste Mode
    cliphist list | rofi -dmenu -replace -theme "$THEME" -p "📋 Clipboard" | cliphist decode | wl-copy
    ;;
esac
