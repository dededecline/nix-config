{ pkgs, ... }: {
  imports = [
    ./home.nix
    ./homebrew.nix
    ./packages.nix
  ];
}
