#!/usr/bin/env bash

# This script is used to show the Z Menu
# Need script: hm_general.sh, hm_theme.sh, hm_setting.sh

# Access: file://~/.local/bin/hm_general.sh
# Access: file://~/.local/bin/hm_theme.sh
# Access: file://~/.local/bin/hm_setting.sh

rofi -show " General" \
  -p "Z Menu - Search" \
  -i \
  -modes " General:~/.local/bin/hm_general.sh, Theme:~/.local/bin/hm_theme.sh, Setting:~/.local/bin/hm_setting.sh"
