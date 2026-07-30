# japanese-input.nix
{ pkgs, ... }: {

  # Resources
  # https://wiki.nixos.org/wiki/Fcitx5
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
  };

  # Some shenanigans here
  # /usr/include/X11/keysymdef.h
  #  cat /usr/share/X11/xkb/symbols/capslock
  # cat /usr/share/X11/xkb/rules/base.lst
  # https://github.com/NapoleonWils0n/cerberus/blob/master/ubuntu/wayland-xkb.org
  # cat ~/.config/kxkbrc
  # WEV
}
