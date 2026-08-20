#!/usr/bin/env bash
set -u

cat << 'EOF'


 _____ _____                      
/  ___|  __ \                     
\ `--.| |  \/ _ __   __ _  ___ ___
 `--. \ | __| '_ \ / _` |/ __/ _ \
/\__/ / |_\ \ |_) | (_| | (_|  __/
\____/ \____/ .__/ \__,_|\___\___|
            | |                   
            |_|                   

EOF

ZSPACE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

chmod +x ./scripts/*
source "./scripts/variables.sh"
source "./scripts/functions.sh"

# ======================================================================================
# MAIN FLOW
# ======================================================================================

print_header
select_window_manager

# ============================================================================
# BLOCK 1: CHECK AND INSTALL DEPENDENCIES
# ============================================================================
step_title "1 - CHECK AND INSTALL DEPENDENCIES (xbps-install, git, curl)"

# Check if xbps-install is available (Void Linux)
if command -v xbps-install >/dev/null 2>&1; then
    log_ok "xbps-install is available (Void Linux)."
else
    log_warn "xbps-install not found. If using another distro, install packages manually."
fi

# Auto-add Hyprland community repo if Hyprland is selected and not found in base Void repos
if [[ " ${SELECTED_WMS[*]} " =~ " hyprland " ]] && command -v xbps-install >/dev/null 2>&1; then
    if ! xbps-query hyprland >/dev/null 2>&1; then
        log_info "Hyprland selected. Adding Void Hyprland community repository..."
        echo 'repository=https://github.com/void-land/hyprland-void-packages/releases/latest/download/' | sudo tee /etc/xbps.d/hyprland-packages.conf >/dev/null
        sudo xbps-install -S >/dev/null 2>&1
        log_ok "Hyprland community repository added successfully."
    fi
fi

DEPENDENCIES=("git" "curl")
for pkg in "${DEPENDENCIES[@]}"; do
    if command -v "$pkg" >/dev/null 2>&1; then
        log_ok "$pkg exists."
    else
        log_warn "$pkg not found."
        if command -v xbps-install >/dev/null 2>&1; then
            if ask_yes_no "===> Install $pkg by xbps-install now?"; then
                sudo xbps-install -Sy "$pkg"
            else
                log_warn "You need $pkg for full installer flow."
            fi
        fi
    fi
done

echo ""
echo -e "${C_BOLD}===================================================================${C_RESET}"
echo -e "${C_GREEN}--- Everything is ready to install Config! ---${C_RESET}"

# ============================================================================
# BLOCK 2: INSTALL PACKAGES
# ============================================================================
step_title "2 - INSTALL PACKAGES FROM LIST"

PKG_LABELS=()
PKG_FILES=()

log_info "You need to install pkg-core.txt & pkg-<WM_NAME>.txt for ZSpace to work properly"
log_info "You can CTRL+C to cancel installing & nano ~/zspace/src/packages/pkg-core.txt to edit package list"

for i in "${!SELECTED_WMS[@]}"; do
    wm_name="${SELECTED_WMS[$i]}"
    wm_upper=$(echo "$wm_name" | tr '[:lower:]' '[:upper:]')
    PKG_LABELS+=("$wm_upper")
    PKG_FILES+=("${SELECTED_PKG_WMS[$i]}")
done

# Add common core, service, optional packages
PKG_LABELS+=("CORE" "SERVICE" "OPTIONAL")
PKG_FILES+=("$PKG_CORE" "$PKG_SERVICE" "$PKG_OPTIONAL")

INSTALL_FLAGS=()
for i in "${!PKG_LABELS[@]}"; do
    INSTALL_FLAGS+=(0)
done

echo ":: Package lists:"
for i in "${!PKG_LABELS[@]}"; do
    echo "   [$i] ${PKG_LABELS[$i]} : Package list from ${PKG_FILES[$i]}"
done
echo ""

for i in "${!PKG_LABELS[@]}"; do
    if ask_yes_no "===> Mark ${PKG_LABELS[$i]} for installation?"; then
        INSTALL_FLAGS[$i]=1
    else
        INSTALL_FLAGS[$i]=0
    fi
done

echo ""
echo ":: Install plan (1=install, 0=skip): [${INSTALL_FLAGS[*]}]"
echo ""

selected_count=0
for i in "${!PKG_LABELS[@]}"; do
    if [[ "${INSTALL_FLAGS[$i]}" -eq 1 ]]; then
        ((selected_count++))
    fi
done

if [[ "$selected_count" -eq 0 ]]; then
    log_skip "No package group selected. Skipping Block 2."
else
    for i in "${!PKG_LABELS[@]}"; do
        if [[ "${INSTALL_FLAGS[$i]}" -eq 1 ]]; then
            install_pkg_file "${PKG_LABELS[$i]}" "${PKG_FILES[$i]}"
        else
            log_skip "[${PKG_LABELS[$i]}] Not selected."
        fi
    done
    log_ok "Block 2 package processing finished."
fi

# ============================================================================
# BLOCK 3: CREATE NECESSARY DIRECTORIES
# ============================================================================
step_title "3 - CREATE NECESSARY DIRECTORIES"

FOLDERS=(
    "$HOME/.config"
    "$HOME/.icons"
    "$HOME/.themes"
    "$HOME/Pictures/Wallpapers"
    "$HOME/Pictures/Screenshots"
    "$HOME/Videos/Wallpapers/Preview"
)

for folder in "${FOLDERS[@]}"; do
    ensure_dir "$folder"
done

log_ok "All necessary directories have been created."

# BLOCK 3.1: NixOS Setup (Optional compatibility)
# =======================================================
# NixOS specific deployment (Online Remote / Offline)
# =======================================================
if command -v nixos-rebuild >/dev/null 2>&1; then
    echo ""
    log_info "NixOS detected. Choose configuration mode for ZSpace Dotfiles:"
    echo -e "  ${C_BOLD}[1]${C_RESET} Offline (Copy zspace-config.nix and edit configuration.nix)"
    echo -e "  ${C_BOLD}[2]${C_RESET} Online Remote (Deploy flake.nix from template)"
    echo -e "  ${C_BOLD}[0]${C_RESET} Skip NixOS deployment"
    read -r -p ">>> Choose mode (1/2/0): " nixos_mode

    NIXOS_ETC="/etc/nixos"
    SOURCE_Z_NIX="$NIX_DIR/zspace-config.nix"
    SOURCE_FLAKE_EXAMPLE="$NIX_DIR/flake.nix.example"

    if [[ "$nixos_mode" == "1" ]]; then
        log_info "Deploying NixOS Offline Config..."
        copy_file "$SOURCE_Z_NIX" "$NIXOS_ETC/zspace-config.nix"
            
        CONFIG_NIX="$NIXOS_ETC/configuration.nix"
        if [[ -f "$CONFIG_NIX" ]]; then
            if grep -q "./zspace-config.nix" "$CONFIG_NIX"; then
                log_skip "./zspace-config.nix is already imported in $CONFIG_NIX."
            else
                log_info "Injecting ./zspace-config.nix into imports of configuration.nix..."
                grep -q '\./zspace-config\.nix' "$CONFIG_NIX" || sudo sed -i '/\.\/hardware-configuration\.nix/a \      .\/zspace-config\.nix' "$CONFIG_NIX"
                log_ok "Updated imports in $CONFIG_NIX."
            fi
        else
            log_warn "$CONFIG_NIX not found! Please import zspace-config.nix manually."
        fi

    elif [[ "$nixos_mode" == "2" ]]; then
        log_info "Deploying NixOS Online Remote Config (Flake)..."
        DEST_FLAKE="$NIXOS_ETC/flake.nix"
            
        if [[ -f "$DEST_FLAKE" ]]; then
            log_warn "$DEST_FLAKE already exists."
            log_warn "ZSpace flake.nix will overwrite your existing flake.nix (backup your own first)."
            if ask_yes_no "===> Do you want to use zspace flake.nix?"; then
                copy_file "$SOURCE_FLAKE_EXAMPLE" "$DEST_FLAKE"
                log_ok "flake.nix overwritten successfully."
            else
                log_skip "Kept existing flake.nix."
            fi
        else
            copy_file "$SOURCE_FLAKE_EXAMPLE" "$DEST_FLAKE"
            log_ok "flake.nix deployed successfully."
        fi
    else
        log_skip "Skipping NixOS specific deployment."
    fi
fi

# ============================================================================
# BLOCK 4: BACKUP AND COPY CONFIG
# ============================================================================
step_title "4 - SETUP ZSPACE CONFIG"

log_info "Backing up existing configs in ~/.config and copying new configs from zspace/src/common/config"
log_warn "Do NOT skip this step in the first time installation of ZSpace"

SOURCE_COMMON_CONFIG="$COMMON_DIR/config"
SOURCE_ONCE_CONFIG="$COMMON_DIR/once-config"
DEST_CONFIG="$HOME/.config"

if ask_yes_no "===> Do you want to setup zspace config now?"; then

    echo ">>> Deploying Common configs..."
    for folder in "$SOURCE_COMMON_CONFIG"/*/; do
        [[ -d "$folder" ]] || continue
        folder_name="$(basename "$folder")"
        if [[ "$folder_name" == "hypr" ]]; then
            continue
        fi
        copy_dir_content "$SOURCE_COMMON_CONFIG/$folder_name" "$DEST_CONFIG/$folder_name"
    done
    copy_file "$SOURCE_COMMON_CONFIG/hypr/hypridle.conf" "$DEST_CONFIG/hypr/hypridle.conf"
    copy_file "$SOURCE_COMMON_CONFIG/hypr/hyprlock.conf" "$DEST_CONFIG/hypr/hyprlock.conf"
    copy_file "$SOURCE_COMMON_CONFIG/hypr/hyprlock_tiny.conf" "$DEST_CONFIG/hypr/hyprlock_tiny.conf"

    # Loop through selected WMs (hyprland will always be last if "ALL" was chosen)
    for i in "${!SELECTED_WMS[@]}"; do
        WM_NAME="${SELECTED_WMS[$i]}"
        WM_DIR_PATH="${SELECTED_WM_DIRS[$i]}"
        SOURCE_WM_CONFIG="$WM_DIR_PATH"

        if [[ $WM_NAME == "hyprland" ]]; then
            echo ">>> Deploying Hyprland configs..."
            copy_dir_content "$SOURCE_WM_CONFIG/config" "$DEST_CONFIG/hypr/config"
            copy_file "$SOURCE_WM_CONFIG/hyprland.lua" "$DEST_CONFIG/hypr/hyprland.lua"
        elif [[ $WM_NAME == "niri" ]]; then
            echo ">>> Deploying Niri configs..."
            copy_dir_content "$SOURCE_WM_CONFIG" "$DEST_CONFIG/niri"
        elif [[ $WM_NAME == "mango" ]]; then
            echo ">>> Deploying Mango configs..."
            copy_dir_content "$SOURCE_WM_CONFIG" "$DEST_CONFIG/mango"
        elif [[ $WM_NAME == "labwc" ]]; then
            echo ">>> Deploying Labwc configs..."
            copy_dir_content "$SOURCE_WM_CONFIG" "$DEST_CONFIG/labwc"
        else
            log_warn "Unknown WM: $WM_NAME. Skipping WM config deployment."
        fi
    done

    echo ">>> Deploying Thunar gtk.css theme..."
    copy_file "$SOURCE_COMMON_CONFIG/gtk.css" "$DEST_CONFIG/gtk-3.0/gtk.css"

    echo ">>> Deploying mimeapps.list..."
    copy_file "$SOURCE_ONCE_CONFIG/mimeapps.list" "$DEST_CONFIG/mimeapps.list"

    echo ">>> Deploying starship.toml (starship configuration)..."
    copy_file "$SOURCE_COMMON_CONFIG/starship.toml" "$DEST_CONFIG/starship.toml"

    echo ">>> Deploying .nanorc (nano configuration)..."
    copy_file "$SOURCE_COMMON_CONFIG/.nanorc" "$HOME/.nanorc"

    log_ok "Configurations deployment finished."
else
    log_skip "Skipping config deployment."
fi

# ============================================================================
# BLOCK 5: BACKUP AND COPY LOCAL BIN
# ============================================================================
step_title "5 - SETUP LOCAL BIN SCRIPTS"

log_info "Backing up existing ~/.local/bin and copying new scripts from zspace/src/common/local/bin"
log_warn "Do NOT skip this step in the first time installation of ZSpace"

SOURCE_BIN="$COMMON_DIR/local/bin"
DEST_BIN="$HOME/.local/bin"

if ask_yes_no "===> Do you want to setup zspace scripts now?"; then
    if [[ -d "$SOURCE_BIN" ]]; then
        copy_dir_content "$SOURCE_BIN" "$DEST_BIN"
        chmod +x ~/.local/bin/*
        log_ok "local/bin deployment completed."
    else
        log_error "Directory not found: $SOURCE_BIN"
    fi
else
    log_skip "Skipping local/bin deployment."
fi

# ============================================================================
# BLOCK 6: CLONE ZSPACE-ARCHIVE AND RUN setup.sh
# ============================================================================
step_title "6 - DEPLOY EXTRA ASSETS FROM zspace-archive"

log_info "Clone zspace-archive to setup icons, themes, and wallpapers."

if ask_yes_no "===> Do you want to setup zspace assets: Icons, Themes and Wallpapers?"; then
    if deploy_assets_from_archive_repo; then
        log_ok "zspace-archive setup completed."
    else
        log_error "zspace-archive setup failed."
    fi
else
    log_skip "Skipping zspace-archive assets setup."
fi

# ============================================================================
# BLOCK 7: FINAL SETUP: MAKE SOMETHING WORK
# ============================================================================
step_title "7 - FINAL SETUP: MAKE SOMETHING WORK"

# Gen style first time
if [[ -x "$HOME/.local/bin/gen_style.sh" ]]; then
    "$HOME/.local/bin/gen_style.sh"
    log_ok "Executed gen_style.sh"
else
    log_warn "Not executable or missing: $HOME/.local/bin/gen_style.sh"
fi

# Change default shell to fish
if command -v fish >/dev/null 2>&1; then
    FISH_PATH="$(command -v fish)"
    
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    
    if [[ "$SHELL" != "$FISH_PATH" ]]; then
        chsh -s "$FISH_PATH" "$USER"
        log_ok "Changed default shell to fish ($FISH_PATH)."
    else
        log_skip "Fish is already your default shell."
    fi
else
    log_warn "Fish shell is not installed. Skipping shell change."
fi

# Init ZSpace Control
check_control_dir

# Check if ly runit service is installed (Void Linux runit)
if [ -d "/etc/sv/ly" ]; then
    if ask_yes_no "===> Do you want to enable ly runit service now?"; then
        sudo ln -sf /etc/sv/ly /var/service/
        log_ok "ly runit service enabled (/var/service/ly)."
    else
        log_skip "Skipping runit service enable."
    fi
else
    log_warn "ly runit service not found in /etc/sv/ly. Skipping service enable."
fi

# Set GNOME color scheme to dark and set Thunar as default file manager
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    log_ok "Set GNOME color scheme to dark."
fi

# Set Thunar as default file manager if installed
if command -v thunar >/dev/null 2>&1; then
    xdg-mime default thunar.desktop inode/directory
    log_ok "Set Thunar as default file manager."
else
    log_warn "Thunar is not installed. Skipping setting default file manager."
fi

echo ""
echo -e "${C_GREEN}All services have been processed!${C_RESET}"
echo ""
echo -e "${C_BOLD}${C_CYAN}>>>>>>>>>> All done! Please restart your pc to apply changes!${C_RESET}"
echo -e "${C_MAGENTA}Backup folder for this run: $BACKUP_DIR${C_RESET}"
