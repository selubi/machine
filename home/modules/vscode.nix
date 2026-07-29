# vscode.nix
{ pkgs, ... }: {
  programs.vscode = {
    enable = true;

    # The description of this option is misleading.
    # This can work if the only profile available is the default profile.
    # e.g. Do not define profile.<name> other than profile.default
    # The compile warning is more correct `warning: programs.vscode.mutableExtensionsDir can be used only if no profiles apart from default are set.`
    # Keep this true for sanity, or you need to change nix settings everytime installing an extension
    mutableExtensionsDir = true;

    profiles.default = {
      userSettings = {
        "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
        "workbench.iconTheme" = "material-icon-theme";
        "editor.formatOnSave" = true;
        "editor.mouseWheelZoom" = true;
        "editor.fontFamily" = "'FiraCode Nerd Font Mono', monospace";
        "editor.fontLigatures" = true;
        "git.confirmSync" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.confirmDelete" = false;
      };
      extensions = with pkgs.vscode-marketplace; [
        monokai.theme-monokai-pro-vscode
        jnoortheen.nix-ide
        pkief.material-icon-theme
      ];
    };
  };
}
