{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "frappe"
          set -g @catppuccin_window_status_style "rounded"

          # Status line configuration
          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_session}"
        '';
      }
    ];

    extraConfig = ''
      # Additional tmux configuration
      set -g mouse on
      set -g default-terminal "tmux-256color"

      # Ensure zsh is the default shell for new windows/panes
      set -g default-command "${pkgs.zsh}/bin/zsh"
      set -g default-shell "${pkgs.zsh}/bin/zsh"
    '';
  };
}
