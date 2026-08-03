# home/modules/plasma.nix

# This command below dumps your current plasma settings into a nix attribute set
# It really helps to tell what you want or wouldn't want to manage declaratively.
#   nix run github:nix-community/plasma-manager

{ options, lib, ... }:
{
  # Guard, don't crash if plasma-manager is not available.
  config = lib.optionalAttrs (options ? programs.plasma) {
    programs.plasma = {
      enable = true;

      # Merge into the existing KDE config files instead of replacing them.
      #
      # KDE keeps a lot of runtime state in the very same files we write here
      # (panel/desktop UUIDs, window positions, tiling layouts, HDR calibration).
      #
      # Same bargain as `mutableExtensionsDir = true` in home/modules/vscode.nix:
      # let the app own its own state, declare only what we actually care about.
      # And the same price -- deleting a setting from this repo leaves the key
      # behind in the KDE file, exactly like a stale extension. Nix stops
      # asserting it; nix does not clean it up. Remove those by hand.
      overrideConfig = false;
    };
  };
}
