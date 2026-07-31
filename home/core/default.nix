# core/default.nix
{
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
  nixpkgs.config.allowUnfree = true;
  xdg.enable = true;

  # Needs relogin after changing
  home.sessionVariables = {
    NXM_FLAKE = nixContext.flakeRef;
    NXM_SHA = nixContext.sha;
    NXM_TARGET = nixContext.targetName;
    NXM_SYSTEM = machineConfig.system;
  };

  # NEVER CHANGE THIS AFTER THE INITIAL INSTALLATION UNLESS YOU KNOW WHAT YOU ARE DOING!
  # If you ever want to change this, you would need to wipe home manager on every machine and re-install it.
  home.stateVersion = "26.05";
}
