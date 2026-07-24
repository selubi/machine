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
    # Custom packages
    # (callPackage ../../pkgs/hms { })
  ];

}
