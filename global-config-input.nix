# global-config-input.nix
# Schemas and actual configuration input.
# config.inputGlobalConfig is intended to be manually edited. Put your machine and user configurations here.
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
        type = lib.types.enum [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];
        description = "The target system architecture for this machine. e.g., x86_64-linux, aarch64-darwin, etc.";
      };
      isNixOS = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this machine is running NixOS.";
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
  # This is just schema / type definition.
  options.inputGlobalConfig = {
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

  # This is the actual configuration you edit.
  config.inputGlobalConfig = {
    flakeRef = "github:selubi/machine";

    machines.selupc = {
      system = "x86_64-linux";
      isNixOS = false;
      users.selubi.homeConfiguration = [ ./modules/home ];
    };
  };
}
