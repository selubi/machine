# home/users/selubi/default.nix
{ pkgs, ... }:
{

  imports = [
    ../../core
    ../../features/cli.nix
    ../../features/machine-update.nix
    ../../features/browser.nix
    ../../features/pdf.nix
    ../../features/password-manager.nix
    ../../features/code-editor.nix
    ../../features/fonts.nix
    ../../features/japanese-input.nix
    ../../features/theme.nix
    ../../features/vcs.nix
    ../../features/multimedia.nix
    ../../features/gui.nix
  ];

  home.packages = with pkgs; [
    bash
    tree
    eza
    htop
    nixfmt
    nixd
    zsh
    nil
    wev
    # Custom packages
    # (callPackage ../../pkgs/hms { })
  ];

}
