{ config, pkgs, lib, user, host, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${user.username} = { pkgs, lib, ... }: {
      home.username = user.username;
      home.homeDirectory = user.homeDirectory;
      
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
        userName = user.githubUsername;
        userEmail = ""; # Will be populated by 1Password
        extraConfig = {
          credential = {
            credentialStore = "cache";
            helper = "manager";
            "https://github.com".username = user.githubUsername;
          };
          core = {
            editor = "code";
            autocrlf = false;
          };
          init.defaultBranch = "main";
          pull.rebase = true;
          rebase.autostash = true;
          include.path = "~/.gitconfig.user";
        };
      };

      home.activation = {
        fetchEmailFrom1Password = let
          op = "${pkgs._1password-cli}/bin/op";
        in lib.hm.dag.entryAfter ["writeBoundary"] ''
          email=$(${op} item get "git-email" --fields email --reveal 2>/dev/null)
          if [ -n "$email" ]; then
            echo "[user]" > ~/.gitconfig.user
            echo "    name = ${user.name}" >> ~/.gitconfig.user
            echo "    email = $email" >> ~/.gitconfig.user
            echo "    username = ${user.githubUsername}" >> ~/.gitconfig.user
            
            # Configure GitHub authentication
            echo "[credential \"https://github.com\"]" >> ~/.gitconfig.user
            echo "    helper = manager" >> ~/.gitconfig.user
            echo "    username = ${user.githubUsername}" >> ~/.gitconfig.user
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
