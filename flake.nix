# https://github.com/NixOS/nixpkgs/commits/master
{
  inputs = {
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/4bbb73beb26f5152a87d3460e6bf76227841ae21.tar.gz";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        cli = import ./cli { inherit pkgs; };
      in
      rec {
        formatter = pkgs.nixpkgs-fmt;

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
        };
      }
    );
}


