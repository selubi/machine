# pdf.nix
{ pkgs, ... }:
{
  imports = [
    ./default-applications.nix
  ];

  home.packages = [
    pkgs.kdePackages.okular
  ];

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = "org.kde.okular.desktop";
  };

}
