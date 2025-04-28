{ pkgs, user, ... }: {
  home-manager.users.${user.username} = _: {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      shellAliases = {
        cat = "bat";
        diff = "difft";
        du = "dust";
        find = "fd";
        ls = "lsd";
        ll = "ls -la";
        fetch = "fastfetch";
        top = "btop";
        update = "darwin-rebuild switch --flake /etc/nix-darwin";
      };
      plugins = [
        {
          name = "oh-my-posh";
          src = pkgs.oh-my-posh;
        }
      ];

      initExtraFirst = ''
        export HISTIGNORE="pwd:ls:cd"
      '';

      initExtra = ''
        # Initialize oh-my-posh with a Nerd Font compatible theme
        eval "$(oh-my-posh init zsh --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/catppuccin_frappe.omp.json)"
      '';
    };
  };
}
