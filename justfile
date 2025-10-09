builder := if os() == "macos" { "darwin-rebuild" } else { "nixos-rebuild" }

update: flake-update switch

clean-update: clean update

flake-update:
  echo "consider ulimit -S -n 2048 if this fails"
  nix flake update

switch:
  sudo {{builder}} switch --flake ./#

clean:
  nix-collect-garbage -d && sudo nix-collect-garbage -d
