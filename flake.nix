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
      globalConfig = (lib.evalModules { modules = [ ./globalConfig.nix ]; }).config.globalConfig;

      genTarget = { machineName, userName }: "${userName}@${machineName}";

      allTargets = lib.concatLists (
        lib.mapAttrsToList (
          machineName: machineConfig:
          lib.mapAttrsToList (userName: userConfig: {
            inherit
              userName
              userConfig
              machineName
              machineConfig
              ;
          }) machineConfig.users
        ) globalConfig.machines
      );
    in
    {
      homeConfigurations = lib.listToAttrs (
        lib.map (
          target:
          let
            targetName = genTarget { inherit (target) machineName userName; };
          in
          {
            name = targetName;
            value = home-manager.lib.homeManagerConfiguration {
              pkgs = import nixpkgs { inherit (target.machineConfig) system; };
              modules = target.userConfig.homeConfiguration;
              extraSpecialArgs = {
                nixContext = {
                  inherit (globalConfig) flakeRef;
                  inherit targetName;
                };
                machineConfig = target.machineConfig // {
                  inherit (target) machineName;
                };
                userConfig = target.userConfig // {
                  inherit (target) userName;
                };
              };
            };
          }
        ) allTargets
      );
    };
}
