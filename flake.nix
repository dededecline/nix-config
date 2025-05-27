{
  description = "Dede's Nix Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-formatter-pack = {
      # use by running `nix fmt`
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
  };

  outputs = {
    self,
    nixpkgs,
    nix-formatter-pack,
    ...
  } @ inputs: let
    inherit (self) outputs;

    users = {
      dani = {
        name = "Dani Klein";
        username = "dani";
        githubUsername = "dededecline";
        homeDirectory = "/Users/dani";
      };
    };

    systemHelpers = import ./lib/system.nix {
      inherit self inputs outputs users;
    };
  in {
    formatter = systemHelpers.forEachSystem (system:
      nix-formatter-pack.lib.mkFormatter {
        pkgs = nixpkgs.legacyPackages.${system};

        config.tools = {
          alejandra.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };
      });
    darwinConfigurations = {
      "athena" = systemHelpers.mkDarwinConfiguration "athena" "dani";
    };
    homeConfigurations = {
      "dani@athena" = systemHelpers.mkHomeConfiguration "aarch64-darwin" "dani" "athena";
    };
    overlays = import ./overlays {inherit inputs;};
  };
}
