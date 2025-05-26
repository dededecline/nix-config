{
  user,
  homebrew-core,
  homebrew-cask,
  homebrew-bundle,
  aerospace-swipe,
  ...
}: {
  nix-homebrew = {
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = false;

    user = user.username;

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
      "MediosZ/homebrew-tap" = aerospace-swipe;
    };

    mutableTaps = false;
    autoMigrate = true;
  };
}
