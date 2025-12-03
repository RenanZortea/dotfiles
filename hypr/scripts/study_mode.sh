#!/bin/bash

# --- CONFIGURATION ---
# We use 'sh -c' to ensure flags work correctly
TERM_CMD="alacritty"
BROWSER="zen-browser"
BASE_DIR="$HOME/rustlearning"

# 1. Select Project
PROJECT=$(fd . "$BASE_DIR" --min-depth 1 --max-depth 1 --type d --exec printf '{/}\n' | rofi -dmenu -p "🦀 Rust Study")

if [ -z "$PROJECT" ]; then
    exit 0
fi

FULL_PATH="$BASE_DIR/$PROJECT"

# 2. Aggressive Close Loop
# We get PIDs of all windows and kill them to ensure they actually close
# This is more reliable than 'closewindow' for browsers
hyprctl clients -j | jq -r '.[].pid' | while read pid; do
    kill "$pid" 2>/dev/null
done

# Wait for cleanup
sleep 0.5

# 3. Launch Browser on Workspace 1
hyprctl dispatch workspace 1
hyprctl dispatch exec "$BROWSER"

# 4. Launch Terminals on Workspace 2
hyprctl dispatch workspace 3
sleep 0.5

# Terminal 1: Shell only
# We wrap in sh -c to ensure the directory path is parsed correctly
hyprctl dispatch exec "sh -c '$TERM_CMD --working-directory \"$FULL_PATH\"'"

hyprctl dispatch workspace 2
sleep 0.5

# Terminal 2: Nvim
# We wrap in sh -c and ensure -e nvim is at the very end
hyprctl dispatch exec "sh -c '$TERM_CMD --working-directory \"$FULL_PATH\" -e nvim'"
