# home/modules/git.nix
{ userConfig, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = userConfig.userName;
      email = userConfig.userEmail;
    };
  };
}
