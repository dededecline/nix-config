{ pkgs, user, host, ... }: {
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

    ];
    casks = [
      "1password"
      "cursor"
      "notion"
      "steam"
      "vlc"
      "zen-browser"
    ];
    masApps = {
      "Parcel" = 639968404;
    };
  };
}
