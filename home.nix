{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      hello
      cowsay
    ];

    username = "selubi";
    homeDirectory = "/home/selubi";

    stateVersion = "26.05";
  };
}