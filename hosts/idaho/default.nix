{
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./sops.nix

    ../../components/console-colors.nix
    ../../components/firewall.nix
    ../../components/fonts.nix
    ../../components/locale.nix
    ../../components/niri.nix
    ../../components/zsh.nix

    ./home
  ];

  nix = {
    enable = true;

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than +3";
    };
  };

  swapDevices = [
    { device = "/dev/nixos-vg/swap"; }
  ];

  zramSwap.enable = true;

  boot = {
    tmp.cleanOnBoot = true;

    initrd.systemd = {
      enable = true;
    };

    initrd.luks.devices = {
      cryptroot = {
        device = "/dev/disk/by-uuid/a8a339c2-a012-4743-91c7-e6cd44fe2c5f";
        allowDiscards = true;  # enables TRIM (see below) and accepts security implications
        preLVM = true;
      };
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [ ];
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.hardware.bolt.enable = true;

  services.udev.packages = with pkgs; [
    platformio-core.udev
  ];

  services.fstrim.enable = true;

  services.udisks2.enable = true;

  services.dbus.implementation = "broker";  # probaly faster than vanilla

  services.irqbalance.enable = true;  # maybe helps with random freezes und er load

  networking = {
    hostName = "idaho";
    domain = "localdomain";
    firewall.allowedTCPPorts = [ 631 3000 8000 8080 8888 ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.printing = {
    enable = true;
    stateless = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  # TODO: yubikey
  #security.pam.yubico = {
  #  mode = "challenge-response";
  #  enable = true;
  #};

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    mosh
    screen

    btop
    dnsutils
    ethtool
    file
    gawk
    gnumake
    gnupg
    gnused
    iftop
    iotop
    lm_sensors
    lsof
    ltrace
    pciutils
    strace
    sysstat
    tree
    usbutils
    which

    gnutar
    p7zip
    unzip
    xz
    zip
    zstd

    eza
    fd
    fzf
    jq
    ripgrep
    wget
  ];

  programs = {
    nh.enable = true;

    mosh.enable = true;

    neovim = {
      enable = true;
      vimAlias = true;
    };

    zsh.zsh-autoenv.enable = true;

    virt-manager.enable = true;
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
    spiceUSBRedirection.enable = true;
  };

  system.stateVersion = "24.11";

}
