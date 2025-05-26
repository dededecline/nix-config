{
  user,
  host,
  myLib,
  ...
}: {
  imports = [
    ../../config
  ];

  networking = {
    inherit (host) hostName localHostName computerName;
  };

  users.users.${user.username} = {
    home = user.homeDirectory;
    inherit (user) shell;
  };

  nix = myLib.mkNixConfig;
  nixpkgs = myLib.mkNixpkgsConfig;
}
