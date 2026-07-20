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
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      homeConfigurations = {
        selupc = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./modules/home
          ];
        };
      };
    };
}
