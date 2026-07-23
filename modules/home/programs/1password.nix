# 1password.nix
#
{ machineConfig, ... }: {

  home.packages = [
    pkgs._1password
    pkgs._1password-gui
  ];
}
