# Nix-Darwin Configuration Structure

This repository has been refactored to provide better organization and abstractions for managing nix-darwin configurations.

## Directory Structure

```
├── flake.nix                 # Main flake file - clean and minimal
├── lib/                      # Utility functions and abstractions
│   └── default.nix          # Common helper functions
├── hosts/                    # Host-specific configurations
│   └── dededevice/          # Configuration for the Dededevice host
│       ├── default.nix      # Main host configuration
│       └── configuration.nix # Host-specific user/host/theme data
├── modules/                  # Custom reusable modules
│   ├── default.nix          # Module index
│   └── homebrew.nix         # Homebrew configuration module
├── config/                   # System configurations (existing)
│   ├── default.nix
│   ├── homebrew.nix
│   ├── home.nix
│   ├── packages.nix
│   └── system.nix
└── theming/                  # Theme configurations (existing)
    └── palettes/
```

## Key Abstractions

### Library Functions (`lib/default.nix`)

- **`mkUser`**: Creates user configuration with sensible defaults
- **`mkHost`**: Creates host configuration with computed values
- **`loadTheme`**: Loads and parses JSON theme files
- **`mkNixConfig`**: Standard nix configuration with GC and optimization
- **`mkNixpkgsConfig`**: Standard nixpkgs configuration for macOS

### Host Configuration Pattern

Each host gets its own directory under `hosts/` with:

1. **`configuration.nix`**: Defines user, host, and theme data using lib functions
2. **`default.nix`**: Main host configuration that imports system configs

### Module System

Custom modules in `modules/` are reusable across hosts and provide clean interfaces for complex configurations like Homebrew.

## Adding a New Host

1. Create a new directory under `hosts/`
2. Add the host to the `hosts` attribute set in `flake.nix`
3. Create `configuration.nix` and `default.nix` in the host directory
4. Use the lib functions to define user, host, and theme data

## Benefits

- **Separation of Concerns**: Each file has a single responsibility
- **Reusability**: Common patterns are abstracted into lib functions
- **Maintainability**: Easy to understand and modify individual components
- **Scalability**: Simple to add new hosts or modify existing ones
- **Type Safety**: Better error messages through structured data 