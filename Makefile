.PHONY: require-version release check fmt env

require-version:
ifndef VERSION
	$(error argument "VERSION" is required)
endif

release: require-version
	@gh release create "$(VERSION)" --title "Release $(VERSION)"

check:
	@shellcheck -o all ./cli/main.sh

fmt:
	@nix fmt

env:
	@nix shell nixpkgs#gh nixpkgs#bashInteractive --command bash
