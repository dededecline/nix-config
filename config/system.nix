{ pkgs, self, ... }: {
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
