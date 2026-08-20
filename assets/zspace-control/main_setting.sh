#!/usr/bin/env bash

# This script is used to set up the main settings for all zspace's scripts.
# DO NOT EDIT THIS LINE :v, used for check main_setting.sh up-to-date when run update.sh
SETTING_VERSION="2.2.2"
echo "ZSpace Control Settings Version: $SETTING_VERSION"

# General Settings
NIGHT_LIGHT_TEMPERATURE=4000
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
SCREENREC_SAVE_DIR="$HOME/Videos"

# Niri use screenshot built-in, so SCREENSHOT_DIR is not used in Niri, you can customize it in ~/zspace-control/niri-custom.kdl
# But if you want to use my screenshot script, just add keybind for that

# Wallpaper Settings
WALL_DIR="$HOME/Pictures/Wallpapers"
WALL_MPV_DIR="$HOME/Videos/Wallpapers"
PREVIEW_DIR="$WALL_MPV_DIR/Preview"
BACKDROP_DIR="/tmp" # Backup backdrop blur image for Niri
AWWW_OPTS="--transition-type random --transition-step 90 --transition-fps 60"
WALL_INTERVAL=300
ACCENT_COLOR_BASED_ON_WALLPAPER=true

# Waybar Mode Settings (waybar_manager.sh)
# Add your custom Waybar modes here, e.g., ("custom1" "custom2")
# You just add your waybar config to ~/zspace-control/waybar with `config` and `style.css` files.
# If name between WAYBAR_MODES_DEAULT and WAYBAR_MODE_USER is the same, WAYBAR_MODE_DEAULT (my theme) will be used.
# Example: WAYBAR_MODE_USER=("custom1"), have ~/zspace-control/waybar/custom1/config and ~/zspace-control/waybar/custom1/style.css
WAYBAR_MODE_USER=()

# Rofi Theme Settings
# You just add your theme "name.rasi" to the ~/zspace-control/rofi folder, and switch to it in Z Menu (Theme tab)

# Z Idle Space Settings (z.sh)
Z_CLOCK_FONT_SIZE=10
Z_GENERAL_FONT_SIZE=11
Z_TERMINAL_FONT_SIZE=14

# Exit Settings (exit.sh)
# Threshold for RAM warning (in Megabytes)
RAM_THRESHOLD_MB=300
EXIT_APP_LIST_USER=()
