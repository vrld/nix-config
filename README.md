# Bootstrap on bare metal:

- format disks and generate hardware config:

    $ sudo -s
    # loadkeys neo
    # nix-shell -p nixUnstable
    # ./install.sh

- copy `/mnt/etc/nixos/hardware-configuration.nix` to the relevant host directory
- set the value of `boot.initrd.luks.devices.root.device`; use `/dev/disk/by-uuid`
- install the config with `nixos-install --flake ...`
