# home/features/cli.nix
{ ... }:
{
  imports = [
    ../modules/fish.nix
    ../modules/home-manager.nix
    ../modules/nh.nix
    ../modules/btop.nix
  ];
}
