{

  networking = {
    nameservers = [ "8.8.8.8" ];
    dhcpcd.enable = false;
    useNetworkd = true;
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
      name = "!lo";
      address = [
        "49.13.59.114/32"
        "2a01:4f8:c17:7837::1/64"
        "fe80::9400:2ff:fe6d:6748/64"
      ];
      routes = [
        { Gateway = "172.31.1.1"; GatewayOnLink = true; }
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
