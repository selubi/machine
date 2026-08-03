# home/features/japanese-input.nix
{
  config,
  options,
  lib,
  pkgs,
  ...
}:
{

  # Possibly needs relogin / restart after changing stuffs here.

  # The goal:
  # Caps Lock -> Toggle between english input (raw keyboard input) and japanese input (mozc hiragana mode)
  # Shift + Caps Lock -> The original functionality of Caps Lock
  # Do this all in user space

  # This is so we can use the standard ANSI (English) keyboard layout with glorious 2U Backspace and 6.25U Spacebar
  # And still have a way to input Japanese.

  # Sounds easy right? **famous last words**

  imports = [
    ../modules/plasma.nix
  ];

  config = lib.mkMerge [
    #####################################
    # Add XKB options
    #####################################
    # XKB is basically the keyboard layout system in Linux.
    # We add the option selubi:hztg_shifted_capslock to the XKB options here
    # The option changes "Caps Lock" to "Zenkaku_Hankaku" and "Shift + Caps Lock" to "Caps_Lock"
    # This happens as a keyboard layout override, so even in event viewer it shows as "Zenkaku_Hankaku"
    # Yes, this will cause issues in applications expecting the symbol Caps_Lock, hopefully thats non existent.
    # Please use a unique namespace for your options, i.e. do not override the "caps" default namespace.

    # Resources:
    # Guides:
    # https://github.com/NapoleonWils0n/cerberus/blob/master/ubuntu/wayland-xkb.org
    # https://who-t.blogspot.com/2020/02/user-specific-xkb-configuration-part-1.html
    # https://who-t.blogspot.com/2020/07/user-specific-xkb-configuration-part-2.html
    # References:
    # `cat /usr/share/X11/xkb/rules/base.lst` - available default options in the system
    # `cat /usr/share/X11/xkb/symbols/capslock` - example default option of capslock
    # `cat /usr/include/X11/keysymdef.h` - Actual names of the keys to write options
    # `wev` - wayland event viewer, use this to debug.

    {

      xdg.configFile."xkb" = {
        source = ../files/xdg/config/xkb;
        recursive = true;
      };
    }

    #####################################
    # Input Method Layer
    #####################################

    # Here we configure fcitx5 (input method framework) and mozc (japanese input method).
    # If you speak languages that can be expressed by the raw keys in your keyboard, you do not need an input method.
    # However Japanese is a complex language with conversions.

    # This setting basically sets up two input methods within fcitx5, default us keyboard and mozc japanese input.
    # Zenkaku_Hankaku, Hangul, and Ctrl + Space are the default keybindings to switch between input methods in fcitx5.
    # This switching between input methods mechanism is the one we're using.
    # Note that some input methods like Mozc may have multiple modes within them, but we are not using this mechanism.

    # Resources
    # https://wiki.nixos.org/wiki/Fcitx5
    # https://wiki.archlinux.org/title/Localization/Japanese
    # https://wiki.archlinux.org/title/Mozc
    # https://wiki.archlinux.org/title/Fcitx5
    # https://wiki.nixos.org/wiki/Mozc
    # https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
    {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {

          # This surpresses some warning about env vars
          # Consider conditionally setting this if we ever do other setups
          waylandFrontend = true;
          addons = with pkgs; [
            # Matches https://archlinux.org/groups/x86_64/fcitx5-im/
            # kdePackages makes the configtool available in System Settings -> Input Method
            kdePackages.fcitx5-configtool
            fcitx5-gtk
            kdePackages.fcitx5-qt

            # Japanese input method with UT dictionary
            fcitx5-mozc-ut
          ];
        };

        # Here we configure the multiple input methods within fcitx5, and their keybindings.
        fcitx5.settings.inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "mozc";
        };
      };
    }

    #####################################
    # Window Manager Layer
    #####################################

    # At this point we have input methods and options ready... But how do we use it?

    # First of all we need to let the window manager know that we want to use the xkb options we set up.

    # For KDE Plasma 6, this is the configuration.
    # In a normal linux system, this would live in ~/.config/kxkbrc
    (lib.optionalAttrs (options ? programs.plasma) {
      programs.plasma = {
        input.keyboard = {
          layouts = [ { layout = "us"; } ];
          options = [ "selubi:hztg_shifted_capslock" ];
        };
      };
    })

    # Second, we need to let the window manager know to use the fcitx input method.
    # For KDE Plasma 6, this is the configuration.
    # In a normal linux system, this would live in ~/.config/kwinrc
    # Or, in a normal KDE Plasma 6 GUI, this is System Settings -> Keyboard -> Virtual Keyboard
    # For other compositors, check https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland

    # What we hand kwin is a path to fcitx5's .desktop file. There are three ways to write
    # that path and they are not equal, so please don't "simplify" this one back:

    # 1. The nix store path, /nix/store/<hash>-fcitx5-with-addons-<ver>/share/applications/...
    #    Works fine, but the hash changes every time fcitx5 updates, so kwinrc gets rewritten
    #    on every single update. Pure noise.
    # 2. A literal "$HOME/.nix-profile/share/applications/...", which is what the KDE GUI writes.
    #    This needs the [$e] marker so KDE expands the variable itself, and it assumes your
    #    profile always sits at ~/.nix-profile. That is not true on NixOS or with nix.useXdg.
    # 3. config.home.profileDirectory, what we actually use.
    #    Home manager works out the correct profile for us: ~/.nix-profile on a normal linux
    #    system, /etc/profiles/per-user/<you> if this ever becomes a NixOS module, or
    #    $XDG_STATE_HOME/nix/profile when nix.useXdg is on. It is already an absolute path,
    #    so we don't need [$e] at all.

    # And we can trust the file is really there. i18n.inputMethod above puts fcitx5 into
    # home.packages, and home.packages is what fills the profile. Same file, same feature,
    # so the setting and the desktop file cannot drift apart.
    (lib.optionalAttrs (options ? programs.plasma) {
      programs.plasma = {
        configFile.kwinrc.Wayland.InputMethod = "${config.home.profileDirectory}/share/applications/org.fcitx.Fcitx5.desktop";
      };
    })
  ];
}
