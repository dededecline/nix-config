{ pkgs, ... }: {
  imports = [
    ./home.nix
    ./homebrew.nix
    ./packages.nix
    ./system.nix
    ./user-and-host.nix
    ../apps
  ];
}
