# home/features/gui.nix
{ ... }: {
  qt = {

    # Kvantum is styled in ./theme.nix
    enable = true;
    kvantum = {
      enable = true;
    };
    style.name = "kvantum";

    # explore this later. this crashes systemsettings.
    # platformTheme.name = "kde";
  };
}
