update:
  sudo nixos-rebuild switch --upgrade --flake ./#

clean:
  nix-collect-garbage -d && sudo nix-collect-garbage -d

clean-update: clean update
