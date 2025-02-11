# Secrets CLI

<div>
  <a href="https://github.com/chris-de-leon/secrets-cli/actions">
  <img src="https://github.com/chris-de-leon/secrets-cli/actions/workflows/release.yml/badge.svg"/>
 </a>
</div>

## Overview

This repository contains a Nix flake for the `Secrets CLI` - a personal dev tool which wraps the lastpass CLI. It offers several benefits over using the lastpass CLI directly:

1. Stable Interface: if I ever change my password manager, then most of my side projects will still use the same commands to manage secrets - no refactoring would be necessary
1. Less Duplication: I no longer need to copy/paste the same scripts that I use for secrets management to each of my side projects
1. Improved Organization: the `Secrets CLI` stores all secrets in a folder named "Dev" in lastpass, which makes it easier to distinguish development passwords from others
1. More consistent: the lastpass CLI has an agent which syncs the local lastpass cache with lastpass servers in an async way. For example, once the `lpass add --sync=now ...` command finishes executing, then it takes additional time for the lastpass agent to communicate these changes to lastpass in the background. During that time, it's possible to re-run the command by mistake and create a duplicate secret. The `Secrets CLI` resolves this by ensuring that the local cache is synced frequently after running commands which modify state.

The `Secrets CLI` offers three commands:

1. `secrets push [-s <suffix>] -f <file-path>`: stores the contents of the file at `<file-path>` as a secret named `Dev/<git-repo-name>/[-suffix]`. This command must be called from somewhere within a git repo.

1. `secrets show [-s <suffix>]`: prints the contents of the secret named `/Dev/<git-repo-name>[-suffix]`. This command must be called from somewhere within a git repo.

1. `secrets version`: prints the current CLI version

## Usage

### Nix CLI

You can invoke the secrets CLI with the `nix run` command:

```sh
nix run github:chris-de-leon/secrets-cli version
```

To invoke a specific version of the CLI, you can run:

```sh
nix run https://github.com/chris-de-leon/secrets-cli/archive/refs/tags/v1.1.0.tar.gz version
```

To enter a Nix shell with the `secrets` executable available, you can run:

```sh
nix develop github:chris-de-leon/secrets-cli

secrets version
```

Or:

```sh
nix develop https://github.com/chris-de-leon/secrets-cli/archive/refs/tags/v1.1.0.tar.gz

secrets version
```

### Nix Development Shell

To use the `secrets-cli` in a flake, you can use something similar to:

```nix
{
  inputs = {
    # This also works:
    # secrets.url = "https://github.com/chris-de-leon/secrets-cli/archive/refs/tags/v1.1.0.tar.gz";
    secrets.url = "github:chris-de-leon/secrets-cli";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, secrets, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              scli = secrets.defaultPackage.${prev.system};
            })
          ];
        };
      in
      rec {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.scli
          ];
        };
      }
    );
}
```
