# home/features/code-editor.nix
{ config, lib, ... }:
{
  imports = [ ../modules/vscode.nix ];

  # Same pattern as browser.nix's defaultBrowser: lets other features
  # reference "the editor" without hardcoding VSCode specifically.
  options.defaultEditor = {
    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "The package other features should use to open a text editor.";
    };
    desktopId = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "The .desktop file id of the default text editor.";
    };
  };

  config = {
    home.sessionVariables = {
      VISUAL = "code --wait";
    };

    xdg.mimeApps.defaultApplications = {
      "application/json" = "code.desktop";
      "application/x-docbook+xml" = "code.desktop";
      "application/x-yaml" = "code.desktop";
      "text/markdown" = "code.desktop";
      "text/plain" = "code.desktop";
      "text/x-cmake" = "code.desktop";
    };

    defaultEditor = {
      package = config.programs.vscode.package;
      desktopId = "code.desktop"; # code-url-handler.desktop is a separate URL-protocol handler, not this
    };
  };
}
