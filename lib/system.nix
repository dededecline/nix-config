{
  self,
  inputs,
  outputs,
  users,
  ...
}: let
  mkDarwinConfiguration = hostname: username:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs outputs hostname self;
        userConfig = users.${username};
      };
      modules = [
        ../hosts/${hostname}
        inputs.home-manager.darwinModules.home-manager
        inputs.lix-module.nixosModules.default
        inputs.mac-app-util.darwinModules.default
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = false;
            user = username;
            mutableTaps = false;
            autoMigrate = true;
            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
              "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
            };
          };
        }
      ];
    };
  mkHomeConfiguration = system: username: hostname:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {inherit system;};
      extraSpecialArgs = {
        inherit inputs outputs self;
        userConfig = users.${username};
        mods = "${self}/modules/home-manager";
      };
      modules = [
        ../home/${username}/${hostname}
      ];
    };
  forEachSystem = inputs.nixpkgs.lib.genAttrs ["aarch64-darwin"];
in {
  inherit mkDarwinConfiguration mkHomeConfiguration forEachSystem;
}
