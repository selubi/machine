# home/features/cli.nix
{ ... }:
{
  imports = [
    # Terminal emulators
    ../modules/ghostty.nix

    ../modules/fish.nix
    ../modules/home-manager.nix
    ../modules/nh.nix
    ../modules/btop.nix
  ];
}
