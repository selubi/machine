# home/features/japanese-input.nix
{ pkgs, ... }: {

  # Possibly needs relogin / restart after changing stuffs here.

  # The goal:
  # Caps Lock -> Toggle between english input (raw keyboard input) and japanese input (mozc hiragana mode)
  # Shift + Caps Lock -> The original functionality of Caps Lock
  #####################################
  # Keyboard layout layer
  #####################################

  xdg.configFile."xkb" = {
    source = ../files/xdg/config/xkb;
    recursive = true;
  };

  # There is still two things needed in keyboard layout layer
  # 1. use fcitx5 as default virtual keyboard (/home/selubi/.config/kwinrc)
  # 2. specify to use the options (~/.config/kxkbrc)

  #####################################
  # Input Method Layer
  #####################################
  # Resources
  # https://wiki.nixos.org/wikni/Fcitx5
  # https://wiki.archlinux.org/title/Localization/Japanese
  # https://wiki.archlinux.org/title/Mozc
  # https://wiki.archlinux.org/title/Fcitx5
  # https://wiki.nixos.org/wiki/Mozc

  # Assumes KDE Plasma 6
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      # This surpresses some warning about env vars
      # In a normal system you would read https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
      waylandFrontend = true;
      addons = with pkgs; [
        # Matches https://archlinux.org/groups/x86_64/fcitx5-im/
        kdePackages.fcitx5-configtool
        fcitx5-gtk
        kdePackages.fcitx5-qt

        # Japanese input method with UT dictionary
        fcitx5-mozc-ut
      ];
    };

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

  # Some shenanigans here
  # /usr/include/X11/keysymdef.h
  #  cat /usr/share/X11/xkb/symbols/capslock
  # cat /usr/share/X11/xkb/rules/base.lst
  # https://github.com/NapoleonWils0n/cerberus/blob/master/ubuntu/wayland-xkb.org
  # cat ~/.config/kxkbrc
  # WEV
}
