{ nixContext, ... }:
{
  programs.nh.enable = true;
  programs.nh.flake = nixContext.flakeRef;
  home.shellAliases.nhs = "nh home switch -a -c ${nixContext.targetName}";
}
