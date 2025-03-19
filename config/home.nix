{ config, pkgs, lib, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.daniklein = { pkgs, lib, ... }: {
      home.username = "daniklein";
      home.homeDirectory = "/Users/daniklein";
      
      programs.home-manager.enable = true;

      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;
        shellAliases = {
          cat = "bat";
          diff = "difft";
          du = "dust";
          find = "fd";
          ls = "ls --color=auto";
          ll = "ls -la";
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
      };

      programs.git = {
        enable = true;
        userName = "dededecline";
        userEmail = ""; # Will be populated by 1Password
        extraConfig = {
          credential = {
            credentialStore = "cache";
            helper = "manager";
            "https://github.com".username = "dededecline";
          };
          core = {
            editor = "code";
            autocrlf = false;
          };
          init.defaultBranch = "main";
          pull.rebase = true;
          rebase.autostash = true;
          include.path = "~/.gitconfig";
        };
      };

      home.activation = {
        fetchEmailFrom1Password = let
          op = "${pkgs._1password-cli}/bin/op";
        in lib.hm.dag.entryAfter ["writeBoundary"] ''
          email=$(${op} item get "git-email" --fields email --reveal 2>/dev/null)
          if [ -n "$email" ]; then
            echo "[user]" > ~/.gitconfig
            echo "    name = Dani Klein" >> ~/.gitconfig
            echo "    email = $email" >> ~/.gitconfig
            echo "    username = dededecline" >> ~/.gitconfig
          fi
        '';
      };

      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      home.stateVersion = "24.11";
    };
  };
} 