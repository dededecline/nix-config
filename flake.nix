{
  description = "Dededevice Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
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

  outputs = inputs@{ self, lix-module, nix-darwin, nixpkgs, home-manager, nix-homebrew, homebrew-cask, homebrew-bundle, homebrew-core }:
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
    configuration = { pkgs, ... }: {
      networking = {
        hostName = host.hostName;
        localHostName = host.localHostName;
        computerName = host.computerName;
      };
      
      users.users.${user.username} = {
        home = user.homeDirectory;
        shell = pkgs.zsh;
      };
      
      environment.systemPackages = with pkgs; [
        # General Applications
        appcleaner
        discord
        raycast
        signal-desktop
        slack
        zoom-us

        # Media Tools
        dejavu_fonts
        ffmpeg
        fd
        font-awesome
        hack-font
        jpegoptim
        meslo-lgs-nf
        noto-fonts
        noto-fonts-emoji
        meslo-lgs-nf
        pngquant

        # Nix Configuration
        nil
        statix

        # Node.js Development
        nodePackages.npm
        nodePackages.prettier
        nodejs

        # Python Development
        black
        python3
        uv
        virtualenv

        # Security Tools
        _1password-cli
        openssh

        # Software Development
        act
        difftastic
        docker
        docker-client
        docker-compose
        flyctl
        gcc
        gh
        git
        git-credential-manager
        go
        google-cloud-sdk
        gopls
        ngrok
        opentofu
        sqlite
        tableplus
        tflint

        # System Management
        bat
        btop
        coreutils
        du-dust
        iftop
        jq
        lsd
        mas
        neofetch
        oh-my-posh
        syncthing
        tree
        unrar
        unzip
        wget
        wireshark
        zip
        zsh

        # Text Editors
        vim
      ];

      nix = {
        gc = {
          automatic = true;
          interval = { Weekday = 0; Hour = 2; Minute = 0; };
          options = "--delete-older-than 30d";
        };
        settings = {
          experimental-features = "nix-command flakes";
        };
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

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

      system = {
        stateVersion = 5;

        defaults = {
          dock = {
            autohide = true;
            launchanim = true;
            orientation = "bottom";
            show-recents = false;
            tilesize = 64;
          };
          finder = {
            _FXShowPosixPathInTitle = true;
          };
          NSGlobalDomain = {
            AppleShowAllExtensions = false;
            ApplePressAndHoldEnabled = true;

            "com.apple.sound.beep.volume" = 0.0;
            "com.apple.sound.beep.feedback" = 0;
          };
          trackpad = {
            Clicking = true;
            TrackpadThreeFingerDrag = false;
          };
        };
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Dededevice
    darwinConfigurations.${host.name} = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 

        home-manager.darwinModules.home-manager
        lix-module.nixosModules.default
        nix-homebrew.darwinModules.nix-homebrew

        # Pass variables to other modules
        {
          _module.args = {
            user = user;
            host = host;
          };
        }

        ./config/home.nix
        ./config/homebrew.nix
        
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
