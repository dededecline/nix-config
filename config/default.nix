{ pkgs, ... }: {
  imports = [
    ./home.nix
    ./homebrew.nix
    ./packages.nix
    ./system.nix
    ../apps
  ];
}
