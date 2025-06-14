{user, ...}: {
  programs.git = {
    enable = true;
    userName = user.githubUsername;
    userEmail = ""; # Will be populated by 1Password
    extraConfig = {
      credential = {
        credentialStore = "cache";
        helper = "manager";
        "https://github.com".username = user.githubUsername;
      };
      core = {
        editor = "nvim";
        autocrlf = false;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autostash = true;
      include.path = "~/.gitconfig.user";
    };
  };
}
