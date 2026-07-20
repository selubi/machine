{
  lib,
  pkgs,
  nixContext,
  userConfig,
  machineConfig,
  ...
}:
{

  home.username = userConfig.userName;
  home.homeDirectory =
    if lib.hasSuffix "darwin" machineConfig.system then
      "/Users/${userConfig.userName}"
    else
      "/home/${userConfig.userName}";

  imports = [ ./suites/cli.nix ];

  home.packages = with pkgs; [
    bash
    tree
    eza
    htop
    nixfmt
    nixd
    zsh
    uv
    # Custom packages
    # (callPackage ../../pkgs/hms { })
  ];

  home.sessionVariables = {
    NXM_FLAKE = nixContext.flakeRef;
    NXM_TARGET = nixContext.targetName;
    NXM_SYSTEM = machineConfig.system;
  };

  # NEVER CHANGE THIS AFTER THE INITIAL INSTALLATION UNLESS YOU KNOW WHAT YOU ARE DOING!
  # If you ever want to change this, you would need to wipe home manager on every machine and re-install it.
  home.stateVersion = "26.05";
}
