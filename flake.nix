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
            machineName: machineCfg:
            lib.forEach machineCfg.users (user: {
              name = "${user.username}@${machineName}";
              value = home-manager.lib.homeManagerConfiguration {
                pkgs = import nixpkgs {
                  inherit (machineCfg) system;
                };
                modules = [ user.homeConfiguration ];
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
