{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
