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
        
        initExtra = ''
          # Initialize oh-my-posh with a Nerd Font compatible theme
          eval "$(oh-my-posh init zsh --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/agnoster.omp.json)"
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
            editor = "cursor";
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
        
        linkFonts = lib.hm.dag.entryAfter ["writeBoundary"] ''
          # Ensure fonts directory exists
          mkdir -p ~/Library/Fonts
          
          # Find JetBrains Mono Nerd Font files and link them to user's Fonts directory
          find ${pkgs.nerdfonts}/share/fonts -name "*JetBrains*Mono*Nerd*Font*.ttf" | while read font; do
            basename=$(basename "$font")
            ln -sf "$font" ~/Library/Fonts/"$basename"
          done
          
          # Find Hack Nerd Font files and link them to user's Fonts directory
          find ${pkgs.nerdfonts}/share/fonts -name "*Hack*Nerd*Font*.ttf" | while read font; do
            basename=$(basename "$font")
            ln -sf "$font" ~/Library/Fonts/"$basename"
          done
          
          # Clear font cache
          atsutil databases -remove 2>/dev/null || true
        '';
        
        configureCursor = lib.hm.dag.entryAfter ["writeBoundary"] ''
          CURSOR_SETTINGS_DIR="$HOME/Library/Application Support/Cursor/User"
          mkdir -p "$CURSOR_SETTINGS_DIR"
          
          # Create or update settings.json for Cursor
          SETTINGS_FILE="$CURSOR_SETTINGS_DIR/settings.json"
          
          # Read existing settings if file exists
          if [ -f "$SETTINGS_FILE" ]; then
            # Backup existing settings
            cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"
            # Update settings using jq if available, otherwise create new
            if command -v jq >/dev/null 2>&1; then
              jq '.editor.fontFamily = "\"JetBrainsMono Nerd Font\", \"Hack Nerd Font\", monospace" | 
                  .editor.fontSize = 14 | 
                  .editor.fontLigatures = true | 
                  .terminal.integrated.fontFamily = "\"JetBrainsMono Nerd Font\", \"Hack Nerd Font\", monospace"' \
                  "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
            else
              echo '{
                "editor.fontFamily": "\"JetBrainsMono Nerd Font\", \"Hack Nerd Font\", monospace",
                "editor.fontSize": 14,
                "editor.fontLigatures": true,
                "terminal.integrated.fontFamily": "\"JetBrainsMono Nerd Font\", \"Hack Nerd Font\", monospace"
              }' > "$SETTINGS_FILE"
            fi
          else
            # Create new settings file
            echo '{
              "editor.fontFamily": "\"JetBrainsMono Nerd Font\", \"Hack Nerd Font\", monospace",
              "editor.fontSize": 14,
              "editor.fontLigatures": true,
              "terminal.integrated.fontFamily": "\"JetBrainsMono Nerd Font\", \"Hack Nerd Font\", monospace"
            }' > "$SETTINGS_FILE"
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
