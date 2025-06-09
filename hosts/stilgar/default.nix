{
  pkgs,
  ...
}:
{
  imports = [
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
    ../../components/zsh.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
    };
  };

  users.defaultUserShell = pkgs.zsh;

  users.users.matthias = {
    isNormalUser = true;
    description = "Matthias";
    extraGroups = [ "wheel" ];
    initialPassword = "dreamsmakegoodstories";
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../idaho/home/matthias/keys/id_ed25519.pub)
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINom6Md4tBKNJ3xxg1fI4jg65ryjpNSkJF06/EPbl3bx'' # mobile
    ];
  };

  system.stateVersion = "25.05";

}
