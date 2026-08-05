# home/features/browser.nix
{ config, lib, ... }:
{
  imports = [
    ../modules/google-chrome.nix
    ../modules/default-applications.nix
  ];

  # Lets other features reference "the browser" without hardcoding which one
  # that is. Swap the engine here later and every feature reading
  # `defaultBrowser.*` follows along instead of silently still launching Chrome.
  options.defaultBrowser = {
    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "The package other features should use to open web content.";
    };
    desktopId = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "The .desktop file id of the default browser.";
    };
  };

  config = {
    defaultBrowser = {
      package = config.programs.google-chrome.finalPackage;
      desktopId = "google-chrome.desktop";
    };

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "text/html" = "google-chrome.desktop";
    };
  };
}
