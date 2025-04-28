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
        export FZF_DEFAULT_OPTS=" \
          --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
          --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
          --color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
          --color=selected-bg:#51576d \
          --color=border:#414559,label:#c6d0f5"
      '';
    };
  };
}
