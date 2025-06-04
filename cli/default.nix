{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}:
pkgs.writeShellApplication {
  name = "secrets";
  runtimeInputs = [pkgs.lastpass-cli];
  text = builtins.readFile ./main.sh;
}
