{ theme, ... }: {
  services.jankyborders = {
    enable = true;
    hidpi = true;
    active_color = "0x99${theme.lavender}";
    inactive_color = "0x33${theme.overlay0}";
  };
}
