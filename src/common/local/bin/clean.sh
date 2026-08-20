#!/usr/bin/env bash

echo "Cleaning cache and unneeded packages..."
echo "This will remove all files in ~/.cache and clean unneeded xbps cache/orphan packages."

read -p "Are you sure you want to proceed? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

rm -rf ~/.cache/*
if command -v xbps-remove >/dev/null 2>&1; then
    sudo xbps-remove -O -o
fi
notify-send "Cache cleaned!"
