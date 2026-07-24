# vscode.nix
{ ... }: {
  programs.vscode = {
    enable = true;

    # The description of this option is misleading.
    # This can work if the only profile available is the default profile.
    # e.g. Do not define profile.<name> other than profile.default
    # The compile warning is more correct `warning: programs.vscode.mutableExtensionsDir can be used only if no profiles apart from default are set.`
    mutableExtensionsDir = true;

    profiles.default = {
      userSettings = {
        "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
        "git.confirmSync" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.confirmDelete" = false;
      };
    };
  };
}
