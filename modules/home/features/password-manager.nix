# password-manager.nix
# For nixos install at system level as its a proper program https://wiki.nixos.org/wiki/1Password
{ pkgs, machineConfig, ... }:
{
  home.packages =
    if !machineConfig.isNixOS then
      [
        pkgs._1password-cli
        pkgs._1password-gui
      ]
    else
      [ ];

}
