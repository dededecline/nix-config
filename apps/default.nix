{ pkgs, ... }: 
let
  helpers = import ../lib/helpers.nix { inherit pkgs; };
  terminal_apps = helpers.filter_ls ./terminal "nix";
  in {
  imports = [
    ./aerospace/aerospace.nix
    ./kitty/kitty.nix
    ./git/git.nix
    ./jankyborders/jankyborders.nix
    ./neovim/neovim.nix
    ./sketchybar/sketchybar.nix
  ] ++ terminal_apps;
}
