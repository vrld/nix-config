builder := if os() == "macos" { "darwin-rebuild" } else { "nixos-rebuild" }

update:
  sudo {{builder}} switch --flake ./#

clean:
  nix-collect-garbage -d && sudo nix-collect-garbage -d

clean-update: clean update
