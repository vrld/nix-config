{
  inputs,
  pkgs,
  outputs,
  color-scheme,
  ...
}: let
  pkgs-stable = import inputs.nixpkgs-stable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
in {
  imports = [
    ./hardware-configuration.nix
    ./nix.nix
    ./sops.nix
    ./networking.nix
    ./locale.nix
    ./style.nix
    ./niri.nix
    inputs.hardware.nixosModules.lenovo-thinkpad-x280
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc
    inputs.home-manager.nixosModules.home-manager
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

  services.hardware.bolt.enable = true;

  services.udisks2.enable = true;

  networking = { hostName = "idaho"; domain = "localdomain"; };
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
      extraGroups = [ "wheel" "docker" "networkmanager" ];
      openssh.authorizedKeys.keys = [ ];
    };
    defaultUserShell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.matthias = import ../../home/matthias;
    extraSpecialArgs = { inherit inputs outputs color-scheme pkgs-stable; };
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
  };

  system.stateVersion = "24.11";

}
