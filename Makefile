MAKEFLAGS += --no-print-directory
SHELL = /bin/bash -eo pipefail

.PHONY: check
check: shellcheck
check: nixcheck
check:
	@echo "All files passed lint check ✅"

.PHONY: shellcheck
shellcheck:
	find . -type f -name "*.sh" -print -exec shellcheck -o all {} +

.PHONY: nixcheck
nixcheck:
	nix run '.#fmt' -- --check .

.PHONY: nixlock
nixlock:
	nix flake lock

.PHONY: nixfmt
nixfmt:
	@nix fmt .

.PHONY: nixdev
nixdev:
	nix develop '.#dev'
