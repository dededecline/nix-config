{ config, pkgs, lib, user, host, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${user.username} = { pkgs, lib, ... }: {
      home.username = user.username;
      home.homeDirectory = user.homeDirectory;
      
      programs.home-manager.enable = true;

      home.activation = {
        fetch-email = let
          op = "${pkgs._1password-cli}/bin/op";
          emailScriptPath = ../scripts/fetch-email.sh;
        in lib.hm.dag.entryAfter ["writeBoundary"] ''
          # Set environment variables for the email fetch script
          export OP_BIN="${op}"
          export USER_NAME="${user.name}"
          export GITHUB_USERNAME="${user.githubUsername}"
          
          # Execute the scripts
          bash ${emailScriptPath}
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
