{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}:
pkgs.writeShellApplication {
  name = "secrets";
  runtimeInputs = [pkgs.lastpass-cli];
  text = builtins.readFile ./main.sh;
  bashOptions = []; # already defined in the script
  runtimeEnv = {
    SECRETS_CLI_VERSION = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../VERSION);
  };
}
