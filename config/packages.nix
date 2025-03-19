{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # General Applications
    appcleaner
    discord
    home-assistant-cli
    signal-desktop
    slack
    zoom-us

    # Media Tools
    dejavu_fonts
    ffmpeg
    fd
    font-awesome
    hack-font
    jpegoptim
    meslo-lgs-nf
    (nerdfonts.override { 
      fonts = [ "JetBrainsMono" "Hack" ]; 
    })
    noto-fonts
    noto-fonts-emoji
    pngquant

    # Nix Configuration
    nil
    nixfmt-rfc-style
    statix

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

    # System Management
    bat
    btop
    coreutils
    du-dust
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

    # Text Editors
    vim
  ];
}
