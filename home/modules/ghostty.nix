# home/modules/ghostty.nix

# Somehow needs restart or you might get desktop errors when launching even though from cli its fine
{ machineConfig, ... }:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    systemd.enable = machineConfig.isLinux;
  };
}
