# google-chrome.nix
# If you search this via option search, it won't pop up.
# Its actually programs.chromium but enabled via dynamic attribute at https://github.com/nix-community/home-manager/blob/3b0e6bbd65869af1beadf5963a99befc179d209f/modules/programs/chromium.nix#L341-L351
{ ... }:
{
  programs.google-chrome = {
    enable = true;

    # commandLineArgs = [
    #   "--enable-features=UseOzonePlatform"
    #   "--ozone-platform=wayland"
    # ];
  };
}
