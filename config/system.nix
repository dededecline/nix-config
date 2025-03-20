{ pkgs, self, ... }: {
  fonts.packages = with pkgs; [
    dejavu_fonts
    font-awesome
    hack-font
    noto-fonts
    noto-fonts-emoji
  ];

  networking = {
    dns = [
      # AdGuard DNS
      "94.140.14.14"
      "94.140.15.15"
    ];
    knownNetworkServices = [
      "Thunderbolt Bridge"
      "Wi-Fi"
    ];
  };

  power = {
    sleep = {
      computer = 30;
      display = 10;
    };
  };
  
  security.pam.enableSudoTouchIdAuth = true;

  system = {
    stateVersion = 5;

    activationScripts.postUserActivation.text = ''  
      defaultbrowser zen
      
      # Following line should allow us to avoid a logout/login cycle when changing settings
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      dock = {
        autohide = true;
        launchanim = true;
        mru-spaces = false;
        orientation = "bottom";
        persistent-others = [];
        show-recents = false;
        tilesize = 64;
      };
      finder = {
        _FXShowPosixPathInTitle = true;
      };
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {
        # UI
        AppleInterfaceStyle = "Dark";

        # Mouse
        ApplePressAndHoldEnabled = true;

        # System
        AppleShowAllExtensions = false;

        # Sound
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;

        # Spellcheck
        NSAutomaticCapitalizationEnabled = false;  
        NSAutomaticDashSubstitutionEnabled = false;  
        NSAutomaticPeriodSubstitutionEnabled = false;  
        NSAutomaticQuoteSubstitutionEnabled = false;  
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = false;
      };
    };
  };
}
