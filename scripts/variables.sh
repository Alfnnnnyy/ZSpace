#!/usr/bin/env bash

# Directories
SOURCE_DIR="$ZSPACE_DIR/src"
ASSETS_DIR="$ZSPACE_DIR/assets"
COMMON_DIR="$SOURCE_DIR/common"
WM_DIR="$SOURCE_DIR/wm"
NIX_DIR="$ZSPACE_DIR/nix"

# Backup directory with timestamp
BACKUP_TS="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$HOME/Backup_$BACKUP_TS"

# Arrays to handle multiple WMs
SELECTED_WMS=()
SELECTED_WM_DIRS=()
SELECTED_PKG_WMS=()

# Package lists
PKG_SERVICE="$SOURCE_DIR/packages/pkg-service.txt"
PKG_CORE="$SOURCE_DIR/packages/pkg-core.txt"
PKG_OPTIONAL="$SOURCE_DIR/packages/pkg-optional.txt"
PKG_HYPRLAND="$SOURCE_DIR/packages/pkg-hyprland.txt"
PKG_NIRI="$SOURCE_DIR/packages/pkg-niri.txt"
PKG_MANGO="$SOURCE_DIR/packages/pkg-mango.txt"
PKG_LABWC="$SOURCE_DIR/packages/pkg-labwc.txt"

# zspace-archive repo URL and directory
ARCHIVE_REPO_URL="https://github.com/hakuimaku/zspace-archive.git"
ARCHIVE_DIR="$HOME/zspace-archive"

# zspace-control directory
ZSPACE_CONTROL_DIR="$ASSETS_DIR/zspace-control"
DEST_CONTROL_DIR="$HOME/zspace-control"
