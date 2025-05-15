{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
    iina
    jpegoptim
    pngquant

    # Nix Configuration
    nil

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
    appcleaner
    bat
    btop
    coreutils
    defaultbrowser
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
    oh-my-posh
    syncthing
    tmux
    tree
    unrar
    unzip
    wget
    wireshark
    zip
    zsh

    # System UI
    aerospace
    jankyborders
    sketchybar

    # Text Editors
    vim
  ];
}
