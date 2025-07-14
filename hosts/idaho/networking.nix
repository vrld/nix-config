{

  networking.networkmanager = {
    enable = true;
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
    settings.StreamLocalBindUnlink = "yes";
  };

}
