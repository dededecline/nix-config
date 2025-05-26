{pkgs, ...}: {
  mkUser = {
    name,
    username,
    githubUsername,
    homeDirectory ? "/Users/${username}",
    shell ? pkgs.zsh,
  }: {
    inherit name username githubUsername homeDirectory shell;
  };

  mkHost = {
    name,
    computerName ? name,
    hostName ? "${name}.local",
    localHostName ? name,
  }: {
    inherit name computerName hostName localHostName;
  };

  loadTheme = path: builtins.fromJSON (builtins.readFile path);

  mkNixConfig = {
    gc = {
      automatic = true;
      interval = {
        Hour = 5;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      interval = {
        Hour = 6;
        Minute = 0;
      };
    };
    settings = {
      experimental-features = "flakes nix-command no-url-literals";
    };
  };

  mkNixpkgsConfig = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
  };
}
