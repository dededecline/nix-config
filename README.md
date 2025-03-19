# Nix-Darwin Configuration

A declarative macOS system configuration using nix-darwin, home-manager, and homebrew.

## Repository Structure

```
/etc/nix-darwin/
├── flake.nix               # Main configuration entry point
├── config/
│   ├── home.nix            # Home-manager configuration
│   └── homebrew.nix        # Homebrew packages and casks
└── README.md               # This file
```

## Features

- **Declarative System Configuration**: Define your entire macOS setup in code
- **Package Management**: Manage packages with Nix and Homebrew
- **Dotfile Management**: Configure your shell and tools with home-manager
- **Reproducible**: Easily replicate your setup on a new machine
- **1Password Integration**: Securely retrieve secrets like Git email

## Setup Tutorial

### Prerequisites

- macOS 12+
- Administrative access

### Installation Steps

1. Install Nix package manager using Lix (recommended):

   ```bash
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
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

1. Edit `flake.nix` to add system-wide packages
2. Edit `homebrew.nix` to add Homebrew packages or casks
3. Edit `home.nix` to add user-specific packages

### Changing User Information

User information is centralized in variables defined in `flake.nix`:

```nix
user = {
  name = "Dani Klein";
  username = "daniklein";
  githubUsername = "dededecline";
};
```

## Customization

### System Preferences

System preferences are configured in the `system.defaults` section of `flake.nix`.

### Shell Configuration

Shell aliases and configuration are defined in the `programs.zsh` section of `home.nix`.

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
