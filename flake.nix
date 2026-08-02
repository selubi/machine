# flake.nix
{
  description = "Selubi's machine configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    # How the hell does a color pallete has its own nix module
    catppuccin.url = "github:catppuccin/nix";

    _1password-shell-plugins.url = "github:1Password/shell-plugins";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;
      globalConfig = import ./global-config-derived.nix {
        inherit lib;
        flake = self;
      };
    in
    {
      inherit globalConfig;

      homeConfigurations = lib.mapAttrs (
        _: targetConfig:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit (targetConfig.machineConfig) system;
            overlays = [
              inputs.nix-vscode-extensions.overlays.default
            ];
          };
          modules = targetConfig.userConfig.homeConfiguration ++ [
            inputs.catppuccin.homeModules.catppuccin
            inputs._1password-shell-plugins.hmModules.default
          ];
          extraSpecialArgs = {
            inherit (targetConfig) nixContext;
            inherit (targetConfig) machineConfig;
            inherit (targetConfig) userConfig;
          };
        }
      ) globalConfig.allHomeManagerTargets;
    };
}
