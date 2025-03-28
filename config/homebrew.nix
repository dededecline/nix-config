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
      "homebrew/services"
    ];
    brews = [
      "displayplacer"
    ];
    casks = [
      # Creativity
      "canva"

      # Smart Home
      "home-assistant"

      # Gaming
      "steam"

      # Security
      "1password"
      "protonvpn"

      # Software Development
      "cursor"

      # System Configuration
      "meetingbar"
      "proton-mail-bridge"

      # Productivity
      "notion"
      "proton-drive"
      "proton-mail"
      "zen-browser"
    ];
    masApps = {
      "Okta Verify" = 490179405;
      "Parcel" = 639968404;
      "Perplexity" = 6714467650;
      "Reeder" = 1529448980;
      "Tot" = 1491071483;
    };
  };
}
