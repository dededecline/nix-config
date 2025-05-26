HOSTNAME ?= $(shell hostname)
FLAKE ?= .#$(HOSTNAME)
HOME_TARGET ?= $(FLAKE)
EXPERIMENTAL ?= --extra-experimental-features "nix-command flakes no-url-literals"

.PHONY: help install-lix install-nix-darwin darwin-rebuild nixos-rebuild \
	home-manager-switch nix-gc flake-update flake-check bootstrap-mac

help:
	@echo "Available targets:"
	@echo "  install-lix          - Install the Nix package manager"
	@echo "  install-nix-darwin   - Install nix-darwin using flake $(FLAKE)"
	@echo "  darwin-rebuild       - Rebuild the nix-darwin configuration"
	@echo "  home-manager-switch  - Switch the Home Manager configuration using flake $(HOME_TARGET)"
	@echo "  nix-gc               - Run Nix garbage collection"
	@echo "  flake-update         - Update flake inputs"
	@echo "  flake-check          - Check the flake for issues"
	@echo "  bootstrap-mac        - Install Nix and nix-darwin sequentially"

install-lix:
	@echo "Installing Lix..."
	@sudo curl -sSf -L https://install.lix.systems/lix | sh -s -- install --nix-build-group-id 350
	@. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	@echo "Lix installation complete."

install-nix-darwin:
	@echo "Installing nix-darwin..."
    @sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
	@nix run nix-darwin $(EXPERIMENTAL) -- switch --flake $(FLAKE)
	@echo "nix-darwin installation complete."

darwin-rebuild:
	@echo "Rebuilding darwin configuration..."
	@darwin-rebuild switch --flake $(FLAKE)
	@echo "Darwin rebuild complete."

home-manager-switch:
	@echo "Switching Home Manager configuration..."
	@home-manager switch --flake $(HOME_TARGET)
	@echo "Home Manager switch complete."

nix-gc:
	@echo "Collecting Nix garbage..."
	@nix-collect-garbage -d
	@echo "Garbage collection complete."

flake-update:
	@echo "Updating flake inputs..."
	@nix flake update
	@echo "Flake update complete."

flake-check:
	@echo "Checking flake..."
	@nix flake check
	@echo "Flake check complete."

bootstrap-mac: install-lix install-nix-darwin
