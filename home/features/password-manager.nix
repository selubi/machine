# home/features/password-manager.nix
{ ... }:
{
  imports = [
    ../modules/1password.nix
  ];
}
