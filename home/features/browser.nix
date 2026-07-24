# browser.nix
{ ... }:
{
  imports = [
    ../programs/google-chrome.nix
    ./default-applications.nix
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "text/html" = "google-chrome.desktop";
  };

}
