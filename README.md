# Nix-Darwin Configuration

## Table of Contents
- [Repository Structure](#repository-structure)
- [Features](#features)
- [Setup Tutorial](#setup-tutorial)
  - [Prerequisites](#prerequisites)
  - [Installation Steps](#installation-steps)
  - [1Password Setup](#1password-setup)
- [Usage Guide](#usage-guide)
  - [Updating Your System](#updating-your-system)
  - [Adding New Packages](#adding-new-packages)
  - [Adding New Applications](#adding-new-applications)
- [Customization](#customization)
  - [System Preferences](#system-preferences)
  - [Shell Configuration](#shell-configuration)
  - [Git Configuration](#git-configuration)
  - [Window Management](#window-management)
- [Troubleshooting](#troubleshooting)

A declarative macOS system configuration using nix-darwin, home-manager, and homebrew.

## Repository Structure

```
/etc/nix-darwin/
├── flake.nix               # Main configuration entry point
├── flake.lock              # Nix flake lock file
├── config/
│   ├── default.nix         # Import all configurations
│   ├── home.nix            # Home-manager configuration
│   ├── homebrew.nix        # Homebrew packages and casks
│   ├── packages.nix        # System packages configuration
│   └── system.nix          # System preferences and defaults
├── apps/
│   ├── default.nix         # Import all app configurations
│   ├── aerospace/          # Aerospace window manager configuration
│   ├── git/                # Git configuration
│   ├── jankyborders/       # Jankyborders configuration
│   ├── kitty/              # Kitty terminal configuration
│   ├── neovim/             # Neovim configuration
│   ├── sketchybar/         # Sketchybar configuration
│   └── terminal/           # Terminal configurations
│       ├── bat.nix         # Bat syntax highlighter configuration
│       ├── lsd.nix         # Modern ls replacement configuration
│       ├── tmux.nix        # Tmux terminal multiplexer configuration
│       └── zsh.nix         # ZSH shell configuration
├── scripts/
│   ├── fetch-email.sh      # Script for 1Password email fetching
│   ├── display-mode.sh     # Script for managing display modes
│   └── manage-mas.sh       # Script for managing Mac App Store apps
├── theming/                # Theme configurations
│   ├── palettes/           # Color palette definitions
│   └── wallpapers/         # Wallpaper collection
├── LICENSE                 # License file
└── README.md               # This file
```

## Features

- **Declarative System Configuration**: Define your entire macOS setup in code
- **Package Management**: Manage packages with Nix and Homebrew
- **Dotfile Management**: Configure your shell and tools with home-manager
- **Reproducible**: Easily replicate your setup on a new machine
- **1Password Integration**: Securely retrieve secrets from 1Password
- **Modular Structure**: Easily maintain and extend configurations
- **External Scripts**: Separation of logic from configuration
- **Window Management**: Tiling window management with Aerospace and Jankyborders
- **Status Bar**: Customizable status bar with Sketchybar
- **Neovim Configuration**: Pre-configured Neovim setup
- **Terminal Configuration**: Kitty terminal with custom theming, plus utilities like tmux, bat, and lsd
- **Theme Management**: Centralized theming system with color palettes and wallpapers

## Setup Tutorial

### Prerequisites

- macOS 12+
- Administrative access

### Installation Steps

1. Install Nix package manager using Lix (recommended):

   ```bash
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install --nix-build-group-id 30000
   ```
   
   - Answer `Y` when prompted to install Nix
   - Answer `Y` when prompted to set up the nix-daemon

2. Source the Nix profile:

   ```bash
   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   ```

3. Create and set permissions for the nix-darwin directory:

   ```bash
   sudo mkdir -p /etc/nix-darwin
   sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
   ```

4. Clone this repository (or create a new one from the template):

   ```bash
   # Option 1: Clone this repository
   git clone https://github.com/dededecline/nixos-config.git /etc/nix-darwin
   
   # Option 2: Create a new configuration from template
   cd /etc/nix-darwin
   nix flake init -t nix-darwin/nix-darwin-24.11
   ```

5. If using Option 2, customize the configuration files to match your needs.

6. Apply the configuration:

   ```bash
   nix run nix-darwin/nix-darwin-24.11#darwin-rebuild -- switch
   ```

7. After the first install, you can use the simplified command:

   ```bash
   darwin-rebuild switch
   ```

### 1Password Setup

This configuration uses 1Password to store sensitive information such as your Git email. To set this up:

1. Install 1Password (already included in the configuration)
2. Create an item in 1Password with the title "git-email" and a field called "email"
3. Ensure you're signed in to 1Password CLI:

   ```bash
   op signin
   ```

## Usage Guide

### Updating Your System

Update and rebuild your system with:

```bash
darwin-rebuild switch --flake /etc/nix-darwin
```

Or use the alias defined in the configuration:

```bash
update
```

### Adding New Packages

1. Edit `config/packages.nix` to add system-wide packages
2. Edit `config/homebrew.nix` to add Homebrew packages or casks
3. Edit `config/home.nix` to add user-specific packages

### Adding New Applications

To add a new application configuration:

1. Create a new directory in `apps/` for your application
2. Create a configuration file (e.g., `myapp.nix`)
3. Add it to the imports in `apps/default.nix`

Example for a new `Home Manager` app configuration:

```nix
# apps/newapp/newapp.nix
{ pkgs, user, ... }: {
  home-manager.users.${user.username} = { ... }: {
    programs.newapp = {
      enable = true;
      # Configuration options here
    };
  };
}
```

Example for a new `nix-darwin` app configuration:

```nix
# apps/newapp/newapp.nix
{ pkgs, ... }: {
  services.newapp = {
    enable = true;
    # Configuration options here
  };
}

```

## Customization

### System Preferences

System preferences are configured in `config/system.nix`.

### Shell Configuration

Shell aliases and configuration are defined in `apps/terminal/zsh.nix`. Additional terminal tools include:
- `tmux` - terminal multiplexer, configured in `apps/terminal/tmux.nix`
- `bat` - syntax highlighting for cat, configured in `apps/terminal/bat.nix`
- `lsd` - modern ls replacement, configured in `apps/terminal/lsd.nix`

### Git Configuration

Git settings are configured in `apps/git/git.nix`.

### Window Management

Aerospace window manager settings are configured in `apps/aerospace/aerospace.nix`.
Jankyborders settings are configured in `apps/jankyborders/jankyborders.nix`.

### Status Bar

Sketchybar configuration is located in `apps/sketchybar/`.

### Editor Configuration

Neovim configuration is located in `apps/neovim/neovim.nix`.

### Theme Configuration

Theming configuration is centralized in the `theming/` directory:
- Color palettes are defined in `theming/palettes/`
- Wallpapers are stored in `theming/wallpapers/`
- Themes can be applied across various applications including Kitty, Neovim, and Sketchybar

## Troubleshooting

If you encounter issues:

1. Check Nix store permissions:
   ```bash
   sudo chown -R root:wheel /nix
   ```

2. Ensure proper permissions on configuration directory:
   ```bash
   sudo chown -R $(id -nu):$(id -ng) /etc/nix-darwin
   ```

3. For more help, consult:
   - [nix-darwin documentation](https://github.com/LnL7/nix-darwin)
   - [home-manager documentation](https://nix-community.github.io/home-manager/)
