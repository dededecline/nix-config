{ config, pkgs, lib, user, host, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${user.username} = { pkgs, lib, ... }: {
      home.username = user.username;
      home.homeDirectory = user.homeDirectory;
      
      programs.home-manager.enable = true;

      home.activation = {
        fetchEmail = let
          op = "${pkgs._1password-cli}/bin/op";
          scriptPath = ../scripts/fetchEmail.sh;
        in lib.hm.dag.entryAfter ["writeBoundary"] ''
          # Set environment variables for the script
          export OP_BIN="${op}"
          export USER_NAME="${user.name}"
          export GITHUB_USERNAME="${user.githubUsername}"
          
          # Execute the script
          bash ${scriptPath}
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
