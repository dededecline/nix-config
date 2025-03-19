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
    brews = [ ];
    casks = [
      "1password"
      "canva"
      "cursor"
      "meetingbar"
      "notion"
      "sol"
      "steam"
      "vlc"
      "zen-browser"
    ];
    masApps = {
      "Amphetamine" = 937984704;
      "Home Assistant" = 1099568401;
      "Okta Verify" = 490179405;
      "Parcel" = 639968404;
      "Perplexity" = 6714467650;
      "Reeder" = 1529448980;
      "Tot" = 1491071483;
    };
  };
}
