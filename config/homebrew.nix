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
    # Mac App Store apps are now managed by scripts/manage-mas.sh
    # until nix 25.05 is stable
  };
}
