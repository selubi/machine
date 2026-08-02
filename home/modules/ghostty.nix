# home/modules/ghostty.nix
{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
  };
}
