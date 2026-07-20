# flake.nix
{
  description = " My machine configurations";

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
      globalConfig = (lib.evalModules { modules = [ ./globalConfig.nix ]; }).config.globalConfig;

      homeConfigurations = lib.listToAttrs (
        lib.concatLists (
          lib.mapAttrsToList (
            machineName: machineConfig:
            lib.forEach machineConfig.users (userConfig: {
              name = "${userConfig.username}@${machineName}";
              value = home-manager.lib.homeManagerConfiguration {
                pkgs = import nixpkgs {
                  inherit (machineConfig) system;
                };
                modules = [ userConfig.homeConfiguration ];
                extraSpecialArgs = {
                  inherit (globalConfig) flakeRef;
                  inherit userConfig;
                  inherit machineConfig;
                };
              };
            })
          ) globalConfig.machines
        )
      );
    in
    {
      inherit homeConfigurations;
    };
}
