# machine-update.nix
# Update your machine with a single command `nxm`
# nixContext provides where to get the updates from, and which target to update.
# You can change the flakeRef easily. For example `nxm .` will use the flake.nix at cwd.
{ nixContext, ... }:
{
  imports = [ ../programs/nh.nix ];

  programs.nh.flake = nixContext.flakeRef;
  home.shellAliases.nxm = "nh ${nixContext.targetType} switch --refresh -a -c ${nixContext.targetName}";
}
