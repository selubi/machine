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

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "com.mitchellh.ghostty.desktop" ];
  };
}
