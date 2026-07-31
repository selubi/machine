# flake.nix
{
  description = "Selubi's machine configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    # How the hell does a color pallete has its own nix module
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-vscode-extensions,
      catppuccin,
      ...
    }:
    let
      lib = nixpkgs.lib;
      globalConfig = import ./global-config-derived.nix { inherit lib; };
    in
    {
      inherit globalConfig;

      homeConfigurations = lib.mapAttrs (
        _: targetConfig:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit (targetConfig.machineConfig) system;
            overlays = [
              nix-vscode-extensions.overlays.default
            ];
          };
          modules = targetConfig.userConfig.homeConfiguration ++ [ catppuccin.homeModules.catppuccin ];
          extraSpecialArgs = {
            inherit (targetConfig) nixContext;
            inherit (targetConfig) machineConfig;
            inherit (targetConfig) userConfig;
          };
        }
      ) globalConfig.allHomeManagerTargets;
    };
}
