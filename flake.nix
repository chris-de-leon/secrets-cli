# https://github.com/NixOS/nixpkgs/commits/master
{
  inputs = {
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/129bbbf4c7edd21cb4ae9607b73a30db7db29eba.tar.gz";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        cli = import ./cli {inherit pkgs;};
      in rec {
        formatter = pkgs.alejandra;

        defaultPackage = cli;

        apps.default = {
          type = "app";
          program = "${defaultPackage}/bin/secrets";
        };

        devShells = {
          default = pkgs.mkShell rec {
            packages = [
              cli
            ];
          };

          dev = pkgs.mkShell rec {
            packages = [
              pkgs.bashInteractive
              pkgs.shellcheck
              pkgs.nodejs
              pkgs.gh
            ];
          };
        };

        packages = {
          fmt = pkgs.alejandra;
        };
      }
    );
}
