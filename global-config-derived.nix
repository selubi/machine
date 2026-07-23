# global-config-derived.nix
# This file transforms the global-config-input.nix into something processable by the flake.nix.
# Its all processing, no manual inputs here.
# Inspect the end result with `nix eval --json .#globalConfig`, its easier to see the result first then try to understand the code.
{ lib, ... }:
let
  inputGlobalConfig =
    (lib.evalModules { modules = [ ./global-config-input.nix ]; }).config.inputGlobalConfig;

  derivedUsers = lib.mapAttrs (userName: user: user // { userName = userName; });

  derivedMachines = lib.mapAttrs (
    machineName: machine:
    machine
    // {
      machineName = machineName;
      isLinux = lib.hasSuffix "linux" machine.system;
      isDarwin = lib.hasSuffix "darwin" machine.system;
      users = derivedUsers machine.users;
    }
  ) inputGlobalConfig.machines;

  genHomeManagerTarget = { userName, machineName }: "${userName}@${machineName}";
in
{
  allHomeManagerTargets = lib.listToAttrs (
    lib.map
      (
        target:
        let
          targetName = genHomeManagerTarget { inherit (target) machineName userName; };
        in
        {
          name = targetName;
          value = {

            inherit (target) userConfig;

            # The target user shouldn't know about other users on the same machine.
            machineConfig = lib.removeAttrs target.machineConfig [ "users" ];

            nixContext = {
              flakeRef = inputGlobalConfig.flakeRef;
              inherit targetName;
            };
          };
        }
      )
      (
        lib.concatLists (
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
          ) derivedMachines
        )
      )
  );
}
