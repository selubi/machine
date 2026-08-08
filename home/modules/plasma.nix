# home/modules/plasma.nix

# This command below dumps your current plasma settings into a nix attribute set
# It really helps to tell what you want or wouldn't want to manage declaratively.
#   nix run github:nix-community/plasma-manager

{
  options,
  lib,
  pkgs,
  ...
}:
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

    # plasma-manager's desktop-script runner shells out to a hardcoded
    # `qdbus`, but this system only has `qdbus6` (qt6-tools) -- plain
    # `qdbus` doesn't exist at all here. Without this, any
    # `programs.plasma.startup.desktopScript` (which is how `panels`
    # applies) fails silently with "qdbus: command not found" -- for
    # `panels` specifically, that means the destructive "remove everything"
    # step still runs, but the "recreate from nix" step never does, and KDE
    # falls back to its own default layout.
    #
    # Not guarded with `builtins.pathExists`/`which` at eval time -- that
    # would make this derivation's content depend on whichever machine
    # happens to build it, which is exactly the kind of impurity this repo
    # avoids. The check belongs at *runtime* instead: the script itself
    # prefers a real `/usr/bin/qdbus` if one's ever present, and only falls
    # back to `qdbus6` when it's not. Same derivation everywhere, still
    # does the right thing on any machine it actually runs on.
    home.packages = [
      (pkgs.writeShellScriptBin "qdbus" ''
        if [ -x /usr/bin/qdbus ]; then
          exec /usr/bin/qdbus "$@"
        fi
        exec qdbus6 "$@"
      '')
    ];
  };
}
