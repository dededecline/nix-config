{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "Catppuccin-frappe";
    };
    themes = let
      catppuccin = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "699f60fc8ec434574ca7451b444b880430319941";
        hash = "sha256-6fWoCH90IGumAMc4buLRWL0N61op+AuMNN9CAR9/OdI=";
      };
    in {
      Catppuccin-frappe.src = "${catppuccin}/themes/Catppuccin Frappe.tmTheme";
    };
  };

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
