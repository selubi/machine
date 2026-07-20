{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      bash
      tree
      eza
      htop
      nh
      fish
      nixfmt
      nixd

      # Custom packages
      (callPackage ../../pkgs/hms { })
    ];

    username = "selubi";
    homeDirectory = "/home/selubi";

    # NEVER CHANGE THIS AFTER THE INITIAL INSTALLATION UNLESS YOU KNOW WHAT YOU ARE DOING!
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
