_: {
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      inline_height = 25;
      records = true;
      secrets_filter = true;
      style = "compact";
    };
  };
}
