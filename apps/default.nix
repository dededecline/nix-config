{ pkgs, ... }: 
let
  helpers = import ../lib/helpers.nix { inherit pkgs; };
  in {
  imports = [
    ./aerospace/aerospace.nix
    ./kitty/kitty.nix
    ./git/git.nix
    ./jankyborders/jankyborders.nix
    ./neovim/neovim.nix
    ./sketchybar/sketchybar.nix
  ] ++ (builtins.map (name: ./terminal + "/${name}")
    (builtins.filter (name: builtins.match ".*\\.nix" name != null)
      (builtins.attrNames (builtins.readDir ./terminal))));
}
