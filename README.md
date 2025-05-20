# Bootstrap on bare metal:

## NixOS (with nixos install media)

- format disks and generate hardware config:

      $ sudo -s
      # loadkeys neo
      # nix-shell -p nixUnstable
      # ./install.sh

- copy `/mnt/etc/nixos/hardware-configuration.nix` to the relevant host directory
- set the value of `boot.initrd.luks.devices.root.device`; use `/dev/disk/by-uuid`
- install the config with `nixos-install --flake ...`

## OSX / nix-darwin

- install [Determinate Nix](https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#determinate-nix-installer) (i.e., with `install --determinate`)
- install [nix-darwin](https://github.com/nix-darwin/nix-darwin)

      sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ...
