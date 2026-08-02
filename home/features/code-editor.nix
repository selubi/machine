# home/features/code-editor.nix
{ ... }: {
  imports = [ ../modules/vscode.nix ];

  home.sessionVariables = {
    VISUAL = "code --wait";
  };
}
