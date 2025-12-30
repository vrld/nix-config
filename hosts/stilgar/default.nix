{
  inputs,
  outputs,
  color-scheme,
  ...
}:
{
  imports = [
    inputs.home-manager-stable.nixosModules.home-manager

    ./hardware-configuration.nix

    ./acme.nix
    ./fail2ban.nix
    ./mta.nix
    ./mqtt.nix
    ./networking.nix
    ./sops.nix
    ./webserver.nix

    ../../components/console-colors.nix
    ../../components/firewall.nix
    ../../components/locale.nix
    ../../components/nix.nix
    ../../components/packages.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
    };
  };

  users.users.matthias = {
    isNormalUser = true;
    description = "Matthias";
    extraGroups = [ "wheel" "nginx" ];
    initialPassword = "dreamsmakegoodstories";
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../idaho/home/matthias/keys/id_ed25519.pub)
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINom6Md4tBKNJ3xxg1fI4jg65ryjpNSkJF06/EPbl3bx'' # mobile
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.matthias = import ./matthias.nix;
    extraSpecialArgs = { inherit inputs outputs color-scheme; };
  };

  system.stateVersion = "25.11";

}
