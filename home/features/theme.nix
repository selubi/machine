# features/theme.nix
{ ... }:
{
  # https://nix.catppuccin.com/
  # Basically we control all application looks here.
  # Compared to defining the themes at each app, this will make things easier to cleanup.

  # Possibly needs relogin / restart after changing stuffs here.
  # (Especially when changing things that is related to the system, e.g. cursor, fcitx5)

  catppuccin = {
    enable = true;
    autoEnable = true;

    # We only need to enable things manually that is not enabled by catppuccin.autoEnable
    # We can search for what those are by searching '"Default: false"' in https://nix.catppuccin.com/
    cursors.enable = true;
    fcitx5.enableRounded = true;
  };

  # As for now, only catppuccin uses these (i.e. the only modification we do is aesthethic)
  # When there are more settings that depends on them, move to standalone module
  home.pointerCursor.enable = true;

}
