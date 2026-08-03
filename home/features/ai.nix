# home/features/ai.nix
{ ... }: {

  imports = [
    ../modules/claude-code.nix
  ];
}
