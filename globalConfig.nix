{ lib, ... }:
let
  # Schema for an individual user profile on a machine
  userSubmodule = lib.types.submodule {
    options = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "The target username on the system.";
      };
      homeDirectory = lib.mkOption {
        type = lib.types.str;
        description = "The absolute path to the user's home directory (e.g., /home/username).";
      };
      homeConfiguration = lib.mkOption {
        type = lib.types.path;
        description = "The local directory or file path pointing directly to the Home Manager configuration.";
      };
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
        type = lib.types.listOf userSubmodule;
        default = [ ];
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
      users = [
        (
          let
            username = "selubi";
          in
          {
            inherit username;
            homeDirectory = "/home/${username}";
            homeConfiguration = ./modules/home;
          }
        )
      ];
    };
  };
}
