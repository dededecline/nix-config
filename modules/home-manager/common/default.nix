{
  outputs,
  userConfig,
  pkgs,
  ...
}: {
  imports = [
    ../programs/aerospace
    ../programs/atuin
    ../programs/bat
    ../programs/btop
    ../programs/fastfetch
    ../programs/fzf
    ../programs/git
    ../programs/go
    ../programs/kitty
    ../programs/lsd
    ../programs/neovim
    ../programs/tmux
    ../programs/zsh
    ../scripts
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home = {
    username = "${userConfig.name}";
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${userConfig.name}"
      else "/home/${userConfig.name}";
  };

  # Ensure common packages are installed
  home.packages = with pkgs;
    [
      # Communication
      discord
      signal-desktop
      slack
      zoom-us

      # Fonts
      dejavu_fonts
      font-awesome
      hack-font
      meslo-lgs-nf
      noto-fonts
      noto-fonts-emoji

      # Media Tools
      ffmpeg
      jpegoptim
      pngquant

      # Node.js Development
      nodePackages.npm
      nodePackages.prettier
      nodejs

      # Python Development
      black
      python3
      uv
      virtualenv

      # Security Tools
      _1password-cli
      openssh

      # Smart Home
      home-assistant-cli

      # Software Development
      act
      difftastic
      docker
      docker-client
      docker-compose
      flyctl
      gcc
      gh
      git
      git-credential-manager
      gnugrep
      go
      google-cloud-sdk
      gopls
      ngrok
      opentofu
      sqlite
      tableplus
      tflint
      utm
      vscode

      # System Management
      atuin
      bat
      btop
      coreutils
      direnv
      du-dust
      fastfetch
      fd
      fzf
      iftop
      jq
      kitty
      lsd
      mkalias
      neovim
      syncthing
      tmux
      tree
      unrar
      unzip
      wget
      wireshark
      zip
      zsh
    ]
    ++ lib.optionals stdenv.isDarwin [
      # Fonts
      sketchybar-app-font

      # Media Tools
      iina

      # System Management
      appcleaner
      defaultbrowser

      # System UI
      aerospace
    ]
    ++ lib.optionals (!stdenv.isDarwin) [];
}
