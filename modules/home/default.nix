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
    if machineConfig.isDarwin then "/Users/${userConfig.userName}" else "/home/${userConfig.userName}";
  targets.genericLinux.enable = machineConfig.isLinux && !machineConfig.isNixOS;
  # NEVER CHANGE THIS AFTER THE INITIAL INSTALLATION UNLESS YOU KNOW WHAT YOU ARE DOING!
  # If you ever want to change this, you would need to wipe home manager on every machine and re-install it.
  home.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./suites/cli.nix
    ./features/machine-update.nix
    ./features/browser.nix
    ./features/pdf.nix
    ./features/password-manager.nix
  ];

  home.packages = with pkgs; [
    bash
    tree
    eza
    htop
    nixfmt
    nixd
    zsh
    # Custom packages
    # (callPackage ../../pkgs/hms { })
  ];

  # Needs reboot after applying
  home.sessionVariables = {
    NXM_FLAKE = nixContext.flakeRef;
    NXM_TARGET = nixContext.targetName;
    NXM_SYSTEM = machineConfig.system;
  };

}
