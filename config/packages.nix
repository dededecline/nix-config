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
    go
    google-cloud-sdk
    gopls
    ngrok
    opentofu
    sqlite
    tableplus
    tflint
    utm

    # System Management
    bat
    btop
    coreutils
    defaultbrowser
    du-dust
    fd
    iftop
    jq
    lsd
    mas
    mkalias
    neofetch
    oh-my-posh
    syncthing
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
