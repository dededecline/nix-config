_: {
  homebrew = {
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    enable = true;
    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/bundle"
    ];
    brews = [
      "displayplacer"
    ];
    casks = [
      # Communication
      "betterdiscord-installer"

      # Creativity
      "canva"

      # Keyboards
      "via"
      "vial"

      # Smart Home
      "home-assistant"

      # Gaming
      "steam"

      # Security
      "1password"
      "protonvpn"

      # System Configuration
      "desktoppr"
      "meetingbar"
      "proton-mail-bridge"

      # Productivity
      "notion"
      "proton-drive"
      "proton-mail"
      "zen-browser"
    ];
    masApps = {
      "Home Assistant" = 1099568401;
      "iMovie" = 408981434;
      "Okta Verify" = 490179405;
      "Parcel" = 639968404;
      "Perplexity" = 6714467650;
      "Reeder" = 1529448980;
      "Tot" = 1491071483;
    };
  };
}
