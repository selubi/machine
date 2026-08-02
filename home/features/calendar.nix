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
    google-calendar = {
      name = "Google Calendar";
      genericName = "Calendar";
      # Now we use the fully configured binary!
      exec = "${chromeBinary} --app=https://calendar.google.com";
      icon = "google-calendar";
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
