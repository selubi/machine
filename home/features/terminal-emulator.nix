# home/features/terminal-emulator.nix
{ config, lib, ... }:
{
  imports = [ ../modules/ghostty.nix ];

  # Same pattern as browser.nix's defaultBrowser: lets other features
  # reference "the terminal" without hardcoding ghostty specifically.
  options.defaultTerminal = {
    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "The package other features should use to open a terminal.";
    };
    desktopId = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "The .desktop file id of the default terminal emulator.";
    };
  };

  config = {
    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "com.mitchellh.ghostty.desktop" ];
    };

    defaultTerminal = {
      package = config.programs.ghostty.package;
      # Not derived from the package via builtins.readDir on purpose: that
      # forces a build at *eval* time (import-from-derivation), and isn't
      # even always unambiguous -- google-chrome ships two .desktop files.
      # A .desktop id is stable upstream identity; a plain string is fine.
      desktopId = "com.mitchellh.ghostty.desktop";
    };
  };
}
