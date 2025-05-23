{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../common/nix.nix
    ../common/fonts.nix
    ./hardware-configuration.nix
    ./sops.nix
    ./networking.nix
    ./locale.nix
    ./console-colors.nix
    ./niri.nix
    inputs.hardware.nixosModules.lenovo-thinkpad-x280
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc

    ./home
  ];

  swapDevices = [
    { device = "/dev/nixos-vg/swap"; }
  ];

  zramSwap.enable = true;

  boot = {
    tmp.cleanOnBoot = true;

    initrd.luks.devices = {
      cryptroot = {
        device = "/dev/disk/by-uuid/a8a339c2-a012-4743-91c7-e6cd44fe2c5f";
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

  services.udisks2.enable = true;

  networking = { hostName = "idaho"; domain = "localdomain"; };
  networking.firewall.enable = lib.mkForce false;
  networking.firewall.allowedTCPPorts = [ 631 3000 8000 8080 8888 ];

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

  users = {
    users.matthias = {
      isNormalUser = true;
      description = "Matthias";
      initialPassword = "dreamsmakegoodstories";
      extraGroups = [ "wheel" "docker" "networkmanager" "tty" "dialout" "libvirtd" ];
      openssh.authorizedKeys.keys = [ ];
    };

    groups.libvirtd.members = ["matthias"];

    defaultUserShell = pkgs.zsh;
  };

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

    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      zsh-autoenv.enable = true;
    };

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
