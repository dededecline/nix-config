{myLib, ...}: let
  user = myLib.mkUser {
    name = "Dani Klein";
    username = "dani";
    githubUsername = "dededecline";
  };

  host = myLib.mkHost {
    name = "Dededevice";
  };

  theme = myLib.loadTheme ../../theming/palettes/catppuccin/frappe.json;
in {
  inherit user host theme;
}
