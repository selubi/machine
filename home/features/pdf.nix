# home/features/pdf.nix
{ pkgs, ... }:
{
  imports = [
    ../modules/default-applications.nix
  ];

  home.packages = [
    pkgs.kdePackages.okular
  ];

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = "org.kde.okular.desktop";
  };

}
