# home/modules/default-applications.nix
{ ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # caching — the whole point
  };
}
