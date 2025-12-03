#!/bin/bash

# --- CONFIG ---
TERM_CMD="alacritty"
BROWSER="zen-browser"
SEARCH_DIRS="$HOME/Projects"

# 1. Find all git repositories
# Finds directories containing .git inside your Projects folder
PROJECT_PATH=$(fd -H "^\.git$" $SEARCH_DIRS --max-depth 4 --type d --exec dirname {} | rofi -theme ~/.config/rofi/launchers/type-4/style-1.rasi -dmenu -i -p "🚀 Open Project")

if [ -z "$PROJECT_PATH" ]; then
    exit 0
fi

PROJECT_NAME=$(basename "$PROJECT_PATH")

# 2. Add to Zoxide
zoxide add "$PROJECT_PATH"

# 3. Cleanup Old Windows (Safe Kill)
# Gets current script PID to avoid killing itself
MY_PID=$(grep -E "PPid:" /proc/$$/status | awk '{print $2}')

hyprctl clients -j | jq -r '.[].pid' | while read pid; do
    if [ "$pid" != "$MY_PID" ]; then
        kill "$pid" 2>/dev/null
    fi
done

# Wait for windows to actually close
sleep 0.5
hyprctl dispatch workspace 1

# --- LAUNCH SEQUENCE ---

# 4. Workspace 1: Browser
# We launch this first because browsers are slow to start.
hyprctl dispatch workspace 1
sleep 0.5
hyprctl dispatch exec "$BROWSER"
sleep 0.5

# 5. Workspace 3: Terminal (Shell)
hyprctl dispatch workspace 3
sleep 0.5
# We use sh -c to safely handle the cd command
hyprctl dispatch exec "sh -c 'cd \"$PROJECT_PATH\" && $TERM_CMD'"
sleep 0.2

# 6. Workspace 2: Neovim (The Focus)
hyprctl dispatch workspace 2
sleep 0.5
# Launch Alacritty directly into Nvim
hyprctl dispatch exec "sh -c 'cd \"$PROJECT_PATH\" && $TERM_CMD -e nvim'"

# --- FINALIZER ---
# Wait a split second for the window to spawn, then force focus again
sleep 0.5
hyprctl dispatch workspace 2
