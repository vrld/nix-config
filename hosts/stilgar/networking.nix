{

  networking = {
    hostName = "stilgar";
    domain = "tutnix.dev";
    firewall.allowedTCPPorts = [
      80
      443
      1883  # mqtt
      9001  # mqtt over websocket
    ];
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;

    networks."10-wan" = {
      matchConfig.Name = "ens3";
      networkConfig.DHCP = "ipv4";
      address = [
        "2a01:4f8:c17:7837::1/64"
      ];
      routes = [
        { Gateway = "fe80::1"; }
      ];
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
    settings.StreamLocalBindUnlink = "yes";
  };

}
