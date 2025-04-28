{ user, pkgs, ... }: {
  home-manager.users.${user.username} = _: {
    programs.lsd = {
      enable = true;
      settings = {
        color = {
          theme = "custom";
        };
        icons = {
          theme = "fancy";
          separator = " ";
        };
        header = true;
        hyperlink = "always";
      };
    };

    xdg.configFile = {
      "lsd/colors.yaml".source =
        let
          catppuccin = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "lsd";
            rev = "7085155432c7fe53a7acd7b0c004955368aa0fba";
            hash = "sha256-lf6VawCgK9VlKO+PAzPD/WqPjxoqw2j000b5ZlEXj/Y=";
          };
        in
        "${catppuccin}/themes/frappe.yaml";
    };
  };
}
