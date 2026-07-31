{ ... }:
{
  # https://nix.catppuccin.com/
  catppuccin = {
    enable = true;
    autoEnable = false;

    btop.enable = true;
    eza.enable = true;
    fish.enable = true;
    vscode.profiles.default = {
      enable = true;
      icons.enable = true;
    };
  };

}
