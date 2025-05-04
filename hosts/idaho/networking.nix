{ ... }: {

  networking = {
    networkmanager.enable = true;

    firewall = {
      enable = true;

      # rate limit SSH connections
      extraCommands = ''
        iptables -I INPUT -p tcp --dport 22 -i eth0 -m state --state NEW -m recent --set
        iptables -I INPUT -p tcp --dport 22 -i eth0 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
      '';
    };
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };

  services.avahi.nssmdns4 = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
    settings.StreamLocalBindUnlink = "yes";
  };

}
