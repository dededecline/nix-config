{mods, ...}: {
  imports = [
    "${mods}/common"
    "${mods}/../homebrew"
  ];

  programs.home-manager.enable = true;

  home = {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.05";

    # Aerospace makes mission control unusable unless apps are grouped
    targets.darwin.defaults."com.apple.dock".expose-group-apps = true;

    activation = {
      fetch-email = let
        op = "${pkgs._1password-cli}/bin/op";
        emailScriptPath = ../scripts/fetch-email.sh;
      in
        lib.hm.dag.entryAfter ["writeBoundary"] ''
          # Set environment variables for the email fetch script
          export OP_BIN="${op}"
          export USER_NAME="${user.name}"
          export GITHUB_USERNAME="${user.githubUsername}"

          # Execute the script
          zsh ${emailScriptPath}

          defaultbrowser zen

          /usr/local/bin/desktoppr ${self}/theming/wallpapers/comfy-home.png

          # Following line should allow us to avoid a logout/login cycle when changing settings
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';
    };
  };
}
