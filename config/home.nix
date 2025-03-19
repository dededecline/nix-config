{ config, pkgs, lib, user, host, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${user.username} = { pkgs, lib, ... }: {
      home.username = user.username;
      home.homeDirectory = user.homeDirectory;
      
      programs.home-manager.enable = true;

      # ZSH configuration moved to apps/zsh/zsh.flake
      # Git configuration moved to apps/git/git.flake

      home.activation = {
        fetchEmailFrom1Password = let
          op = "${pkgs._1password-cli}/bin/op";
        in lib.hm.dag.entryAfter ["writeBoundary"] ''
          # Check if gitconfig.user exists and has an email field with content
          if [ -f ~/.gitconfig.user ] && grep -E -q "email = .+" ~/.gitconfig.user; then
            # Email already exists, just make sure GitHub credentials are set
            if ! grep -q "credential \"https://github.com\"" ~/.gitconfig.user; then
              # Add GitHub credentials section
              echo "" >> ~/.gitconfig.user
              echo "[credential \"https://github.com\"]" >> ~/.gitconfig.user
              echo "    helper = manager" >> ~/.gitconfig.user
              echo "    username = ${user.githubUsername}" >> ~/.gitconfig.user
            fi
          else
            # No existing email, fetch from 1Password
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
      };

      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      home.stateVersion = "24.11";
    };
  };
}
