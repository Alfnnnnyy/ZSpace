<div align="center">

# ZSpace (Void Linux Port)
Hyprland / Niri / MangoWM / Labwc dotfiles for Void Linux

</div>

## Credit

ZSpace is a personal Void Linux port based on HakuSpace by hakuimaku.
Original project:
https://github.com/hakuimaku/hakuspace

---

- Multi-WM Support: Hyprland, Niri, MangoWM, Labwc with seamless switching between window managers.
- Target Distro: Void Linux (migrated to `xbps` package manager and `runit` init system).
- DE-like Experience: Modular UI powered by Rofi, Waybar, SwayNC, and custom scripts.
- Extensible: Highly customizable and easy to adapt to your own workflow.

---

## Key Features

* **Control Center**: `~/zspace-control` this directory stores your custom configs so you don't have to touch the main ones, giving you much more freedom to customize.
* **Accent Colors**: Synced across **Waybar**, **Rofi**, **Kitty**, **Swaync**,... giving your setup a **Super Clean** and **Cohesive Vibe**!
* **Smart Accent Color:** Automatically generates the accent color based on your current wallpaper.
* **Flexible Waybar Layouts:** Support layouts: `top`, `left`, `coredge`, `minimal`, `full`, `neon`.
* **Unique Cava Underbar:** Dynamic audio visualizer waves seamlessly layered directly beneath the Waybar.
* **Wallpaper Automation:** Wallpapers change automatically every 5 minutes.
* **Dockbar:** Built-in Waybar with `wlr/taskbar` module to pin applications.

---

## Programs & Package Management

Package management is fully migrated from Arch `pacman`/`yay` to Void Linux `xbps`.

See package lists in:
- `src/packages/pkg-core.txt`
- `src/packages/pkg-service.txt`
- `src/packages/pkg-optional.txt`
- `src/packages/pkg-hyprland.txt`
- `src/packages/pkg-niri.txt`
- `src/packages/pkg-mango.txt`
- `src/packages/pkg-labwc.txt`

| Component | Program |
|---|---|
| Terminal | [Kitty](https://github.com/kovidgoyal/kitty) |
| App Launcher | [Rofi](https://github.com/davatorium/rofi) |
| Status Bar | [Waybar](https://github.com/alexays/waybar) |
| Shell | [Fish](https://fishshell.com/) + [Starship](https://starship.rs/) |
| File Manager | [Thunar](https://docs.xfce.org/xfce/thunar/start) |
| Notifications & Control Center | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) |
| Wallpaper | [Awww](https://codeberg.org/LGFae/awww) |
| Idle Management | [Hypridle](https://github.com/hyprwm/hypridle) |
| Screen Lock | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| Editor | [VS Code](https://code.visualstudio.com/) |
| Browser | [Firefox](https://www.firefox.com/en-US/) |
| Screen Recording | [Wl-screenrec](https://github.com/russelltg/wl-screenrec) |
| Display Manager | [Ly](https://codeberg.org/fairyglade/ly) (Runit service in `/etc/sv/ly`) |

---

## Installation Guide (Void Linux)

### 1. Clone ZSpace
```bash
cd ~
git clone <your-zspace-repo-url> ~/zspace
```

### 2. Run Installation Script
```bash
cd ~/zspace
chmod +x install.sh
./install.sh
```

The script will handle package installation via `xbps-install`, setup configuration files, and enable the `ly` runit service (`/var/service/ly`).

### 3. Update ZSpace
```bash
cd ~/zspace
chmod +x update.sh
./update.sh
```

---

## Keybindings

- Hotkeys:

| Bind | Function |
|------|----------|
| SUPER + Q | Open Kitty Terminal |
| SUPER + C | Kill Focus Window |
| SUPER + TAB | Open Menu (`zmenu.sh`) |
| SUPER + R | App Menu |
| SUPER + W | Toggle Dockbar |
| SUPER + P | Screenshot |
| SUPER + Z | Toggle Floating |
| SUPER + V | Open Clipboard History |
| SUPER + A/S | Focus Left/Right Window |
| SUPER + Y | Wallpaper Select |
| SUPER + SHIFT + Y | Lively Wallpaper Select |
| SUPER + SHIFT + W | Cycle Waybar Mode |

---

## Directory Structure

- Custom config (your personal changes): `~/zspace-control`
- Icons: `~/.icons`
- Themes: `~/.themes`
- All zspace scripts: `~/.local/bin`
- Fastfetch logo: `~/.config/fastfetch`
- Wallpapers: `~/Pictures/Wallpapers`
- State file & Z Theme: `~/.local/state/z_theme`
