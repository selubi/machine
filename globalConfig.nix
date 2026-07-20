{ lib, ... }:
let
  # Schema for an individual user profile on a machine
  userSubmodule = lib.types.submodule {
    options.homeConfiguration = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      description = "The list of file paths containing the Home Manager configuration.
      This will directly be passed to the home-manager module as the 'modules' argument.";
    };
  };

  # Schema for a machine configuration, which can contain multiple user profiles
  machineSubmodule = lib.types.submodule {
    options = {
      system = lib.mkOption {
        type = lib.types.str;
        description = "The target architecture/OS triplet for this host (e.g., x86_64-linux).";
      };
      users = lib.mkOption {
        type = lib.types.attrsOf userSubmodule;
        default = { };
        description = "A list of target user profiles provisioned on this specific machine.";
      };
    };
  };
in
{
  # This is just schema / type definition for globalConfig.
  options.globalConfig = {
    flakeRef = lib.mkOption {
      description = "The canonical flake reference for this repository.";
      type = lib.types.str;
    };

    machines = lib.mkOption {
      description = "Mapping of machines to its configuration.";
      type = lib.types.attrsOf machineSubmodule;
      default = { };
    };
  };

  # This is the actual configuration for globalConfig.
  config.globalConfig = {
    flakeRef = "github:selubi/machine";

    machines.selupc = {
      system = "x86_64-linux";
      users.selubi.homeConfiguration = [ ./modules/home ];
    };
  };
}
