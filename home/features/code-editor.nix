# home/features/code-editor.nix
{ ... }: {
  imports = [ ../modules/vscode.nix ];

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
}
