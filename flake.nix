# flake.nix
{
  description = "Selubi's machine configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      globalConfig = import ./global-config-derived.nix { inherit lib; };
    in
    {
      inherit globalConfig;

      homeConfigurations = lib.mapAttrs (
        _: targetConfig:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit (targetConfig.machineConfig) system; };
          modules = targetConfig.userConfig.homeConfiguration;
          extraSpecialArgs = {
            inherit (targetConfig) nixContext;
            inherit (targetConfig) machineConfig;
            inherit (targetConfig) userConfig;
          };
        }
      ) globalConfig.allHomeManagerTargets;
    };
}
