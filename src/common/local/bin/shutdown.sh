#!/usr/bin/env bash

# List options
options="󰤄 Hibernate
 Reboot
󰤆 Power Off
󰒲 Sleep
󱅞 Lock
󰩈 Exit"

# Design rofi
chosen=$(echo -e "$options" | rofi -dmenu -p "Shutdown" -i -theme-str 'window
{
    width: 30%;
    height: 50%;
}')

# List action
case $chosen in 
    *"Hibernate"*) loginctl hibernate ;;
    *"Reboot"*) loginctl reboot ;;
    *"Power Off"*) loginctl poweroff ;;
    *"Sleep"*) loginctl suspend ;;
    *"Lock"*) ~/.local/bin/lock.sh ;;
    *"Exit"*) ~/.local/bin/exit.sh ;;
esac
