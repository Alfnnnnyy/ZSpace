# Directory Structure & Architecture Specification

This document provides a detailed breakdown of the `zspace` repository layout, explaining the exact responsibility and scope of each directory and core execution script.

```text
zspace (root)
├── assets/
│   ├── browser/             # Custom userChrome.css & newtab.html for Firefox
│   └── zspace-control/      # Templates for zspace-control
│
├── docs/                    # Documentation for my dots
├── nix/                     # Declarative Nix configuration
├── scripts/                 # Core helper libraries for execution
├── src/
│   ├── common/              # Global dotfiles & assets shared by all WMs
│   ├── packages/            # Package definitions for Void Linux (xbps)
│   └── wm/                  # Window manager configurations
│       ├── hyprland/        # Hyprland setup
│       ├── labwc/           # Labwc setup
│       ├── mango/           # MangoWM setup
│       └── niri/            # Niri setup
│
├── CREDIT                   # Original source credit to HakuSpace
├── LICENSE                  # License file
├── README.md                # Project landing page & user guide
├── install.sh               # Master installer script
└── update.sh                # System updater script
```

### Core Execution Files (Root Directory)

* **`install.sh`**: The primary installation script, use this for first-time setup on Void Linux. Handles package installation via `xbps-install`, setup configuration from `src/`, and deploying initial control templates from `assets/`.
* **`update.sh`**: The update script. Pulls the latest repository changes, updates configurations and ensures zspace-control templates are current.

### 1. `scripts/` (Core Helper Libraries)

* **`functions.sh`**: Common bash functions for installation, packaging, and logging.
* **`variables.sh`**: Path variables and directory constants.

### 2. `src/` (Source Dotfiles and Assets)

* **`src/common/config/`**: Configuration files copied directly to `~/.config`.
* **`src/common/local/bin/`**: Execution scripts copied to `~/.local/bin`.
* **`src/packages/`**: Package lists for Void Linux (`pkg-core.txt`, `pkg-service.txt`, `pkg-optional.txt`, etc.).
* **`src/wm/`**: Window manager specific configurations.

### 3. `assets/` (Control Templates & Web Assets)

* **`assets/browser/`**: Custom web assets including `userChrome.css` for Firefox UI mods and `newtab.html`.
* **`assets/zspace-control/`**: Template files for the ZSpace Control Center.

### 4. `docs/` (Documentation)

* Project documentation guides.
