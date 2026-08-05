# home/features/mail.nix
{ config, lib, ... }:

let
  browserBinary = lib.getExe config.defaultBrowser.package;
in
{
  imports = [
    ../modules/default-applications.nix
    ./browser.nix
  ];

  xdg.desktopEntries = {
    gmail = {
      name = "Gmail";
      genericName = "Email Client";
      # The %u ensures that clicked email addresses get passed to the Gmail window
      exec = "${browserBinary} --app=https://mail.google.com/mail/ %u";
      icon = "gmail"; # Standard icon themes like Papirus have a dedicated 'gmail' icon
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "Email"
      ];
      mimeType = [
        "x-scheme-handler/mailto"
        "message/rfc822"
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/mailto" = "gmail.desktop";
  };
}
