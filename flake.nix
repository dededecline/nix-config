{
  description = "Dededevice Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew"; 
    
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, lix-module, nix-darwin, nixpkgs, home-manager, nix-homebrew, homebrew-cask, homebrew-bundle, homebrew-core, mac-app-util }:
  let
    # Define common variables
    user = {
      name = "Dani Klein";
      username = "daniklein";
      githubUsername = "dededecline";
    };

    user.homeDirectory = "/Users/${user.username}";
    
    host = {
      name = "Dededevice";
      computerName = "Dededevice";
      hostName = "Dededevice.local";
      localHostName = "Dededevice";
    };
    
    # Configuration with variables
    configuration = { pkgs, config, ... }: {
      networking = {
        inherit (host) hostName;
        inherit (host) localHostName;
        inherit (host) computerName;
      };
      
      users.users.${user.username} = {
        home = user.homeDirectory;
        shell = pkgs.zsh;
      };
      
      nix = {
        gc = {
          automatic = true;
          interval = { Weekday = 0; Hour = 2; Minute = 0; };
          options = "--delete-older-than 7d";
        };
        settings = {
          experimental-features = "nix-command flakes";
        };
      };

      # Nixpkgs config
      nixpkgs = {
        hostPlatform = "aarch64-darwin";
        config = {
          allowUnfree = true;
          allowBroken = false;
          allowInsecure = false;
          allowUnsupportedSystem = false;
        };
      };

      # System configuration moved to config/system.nix
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Dededevice
    darwinConfigurations.${host.name} = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        
        # Pass variables to other modules
        {
          _module.args = {
            inherit user host self;
          };
        }

        ./config/default.nix

        home-manager.darwinModules.home-manager
        lix-module.nixosModules.default
        nix-homebrew.darwinModules.nix-homebrew
        mac-app-util.darwinModules.default        
        
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = false;

            # User owning the Homebrew prefix
            user = user.username;

            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };

            mutableTaps = false;
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
