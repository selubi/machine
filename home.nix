{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      hello
    ];

    username = "selubi";
    homeDirectory = "/home/selubi";

    stateVersion = "23.11";
  }
}