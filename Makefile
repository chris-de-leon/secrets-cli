.PHONY: release check fmt env

release:
	@VERSION=$$(nix develop --command secrets version) \
		gh release create "$$VERSION" --title "Release $$VERSION" --generate-notes

check:
	@shellcheck -o all ./cli/main.sh

fmt:
	@nix fmt

env:
	@nix shell nixpkgs#gh nixpkgs#bashInteractive --command bash
