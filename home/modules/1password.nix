# home/modules/1password.nix
{
  pkgs,
  options,
  lib,
  machineConfig,
  ...
}:
{

  config = {
    # For nixos install at system level as its a proper program https://wiki.nixos.org/wiki/1Password
    home.packages =
      if machineConfig.isLinux && !machineConfig.isNixOS then
        with pkgs;
        [
          _1password-cli
          _1password-gui
        ]
      else
        [ ];

    # 1password shell plugins
    # https://www.1password.dev/cli/shell-plugins/nix
    # Guard in case 1password-shell-plugins is not available in the flake inputs
    programs = lib.optionalAttrs (options.programs ? _1password-shell-plugins) {
      _1password-shell-plugins = {
        enable = true;
      };
    };
  };

}
