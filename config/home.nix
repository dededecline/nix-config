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
        # Git email configuration moved to apps/git/git.flake
        
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
