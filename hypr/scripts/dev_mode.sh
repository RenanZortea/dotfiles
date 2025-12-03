#!/bin/bash

# --- CONFIGURATION ---
TERM_CMD="alacritty"
BROWSER="zen-browser"
DEFAULT_DEV_DIR="$HOME"

# 1. Ask for Project Path
PROJECT_INPUT=$(echo -e "" | rofi -dmenu -p "💻 Dev Project Path")

if [ -z "$PROJECT_INPUT" ]; then
    exit 0
fi

if [[ "$PROJECT_INPUT" == /* ]]; then
    TARGET_DIR="$PROJECT_INPUT"
else
    TARGET_DIR="$DEFAULT_DEV_DIR/$PROJECT_INPUT"
fi

if [ ! -d "$TARGET_DIR" ]; then
    notify-send "Error" "Directory $TARGET_DIR does not exist."
    exit 1
fi

# 2. Close All Windows
hyprctl clients -j | jq -r '.[].address' | xargs -I {} hyprctl dispatch closewindow address:{}
sleep 0.5

# 3. Launch Browser on Workspace 1
hyprctl dispatch exec "[workspace 1 silent] $BROWSER"

# 4. Launch Terminals on Workspace 2
hyprctl dispatch exec "[workspace 3] $TERM_CMD --working-directory \"$TARGET_DIR\""
sleep 0.2
hyprctl dispatch exec "[workspace 2] $TERM_CMD --working-directory \"$TARGET_DIR\" -e nvim"

# Focus Workspace 2
hyprctl dispatch workspace 2
