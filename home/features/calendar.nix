# home/features/calendar.nix
{ config, lib, ... }:

let
  # Whatever browser.nix decided the default browser is -- not hardcoded to
  # Chrome here, so this keeps working if that ever changes.
  browserBinary = lib.getExe config.defaultBrowser.package;
in
{
  imports = [
    ../modules/default-applications.nix
    ./browser.nix
  ];

  xdg.desktopEntries = {
    google-calendar = {
      name = "Google Calendar";
      genericName = "Calendar";
      exec = "${browserBinary} --app=https://calendar.google.com";
      icon = "google-agenda"; # The icon in papirus is called "google-agenda"
      terminal = false;
      type = "Application";
      categories = [
        "Calendar"
        "Office"
      ];
      mimeType = [
        "text/calendar"
        "x-scheme-handler/webcal"
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/calendar" = "google-calendar.desktop";
    "x-scheme-handler/webcal" = "google-calendar.desktop";
  };
}
