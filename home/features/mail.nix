# home/features/calendar.nix
{ config, lib, ... }:

let
  # Grab the final, fully configured package that Home Manager builds
  chromePackage = config.programs.google-chrome.finalPackage;

  # The binary name can sometimes change depending on the package (e.g., stable vs beta),
  # so we extract the meta.mainProgram attribute if it exists, otherwise fallback to the default.
  chromeBinary = lib.getExe chromePackage;
in
{
  imports = [
    ../modules/default-applications.nix
    ../modules/google-chrome.nix
  ];

  xdg.desktopEntries = {
    gmail = {
      name = "Gmail";
      genericName = "Email Client";
      # The %u ensures that clicked email addresses get passed to the Gmail window
      exec = "${chromeBinary} --app=https://mail.google.com/mail/ %u";
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
