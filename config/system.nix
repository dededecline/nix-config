{ pkgs, self, ... }: {
  fonts.packages = with pkgs; [
    dejavu_fonts
    font-awesome
    hack-font
    noto-fonts
    noto-fonts-emoji
    sf-mono-liga-bin
    sketchybar-app-font
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

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    stateVersion = 5;

    primaryUser = "dani";

    activationScripts = {
      pua = {
        text = ''
          defaultbrowser zen

          /usr/local/bin/desktoppr ${self}/theming/wallpapers/comfy-home.png

          # (Workaround) install mas manually
          ${self}/scripts/manage-mas.sh
          
          displayplacer \
            "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:2056x1329 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
            "id:B42D6CB3-57EB-488B-88C2-8F68E0376445 res:2560x1600 hz:120 color_depth:8 enabled:true scaling:on origin:(-251,-1600) degree:0" \
            "id:682D7D78-8DD2-468B-A3E4-7F0478C075B5 res:3008x1692 hz:120 color_depth:8 enabled:true scaling:on origin:(-3008,-173) degree:0"
          
          # Following line should allow us to avoid a logout/login cycle when changing settings
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';
      };
    };

    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      controlcenter = {
        BatteryShowPercentage = true;
        Bluetooth = true;
      };
      CustomUserPreferences = {
        # Easiest way to figure these values out is to set them manually
        # Then run `defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys`
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotkeys = {
            # Sets 'copy selected screenshot area to clipboard' shortcut to cmd+ctrl+w
            "31" = {
              enabled = true;
              value = {
                parameters = [ 119 13 1310720 ];
                type = "standard";
              };
            };
          };
        };
      };
      dock = {
        autohide = true;
        launchanim = true;
        mru-spaces = false;
        orientation = "bottom";
        persistent-others = [ ];
        show-recents = false;
        tilesize = 64;
      };
      finder = {
        _FXShowPosixPathInTitle = true;
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = false;
        FXDefaultSearchScope = "SCcf"; # Search current folder by default
        QuitMenuItem = true;
      };
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {
        # Finder
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSTableViewDefaultSizeMode = 1; # Small

        # UI
        AppleInterfaceStyle = "Dark";
        _HIHideMenuBar = true;

        # Mouse
        ApplePressAndHoldEnabled = false;

        # System
        AppleShowAllExtensions = false;
        AppleShowAllFiles = true;
        NSDisableAutomaticTermination = false;

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
      screencapture = {
        disable-shadow = true;
        show-thumbnail = false;
        target = "clipboard";
        type = "png";
      };
      trackpad = {
        Clicking = false;
        TrackpadThreeFingerDrag = false;
      };
    };
  };
}
