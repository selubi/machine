# home/features/vcs.nix
{ ... }: {
  imports = [
    ../modules/git.nix
    ../modules/gh.nix
  ];
}
