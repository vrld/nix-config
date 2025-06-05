{ ... }: {

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
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
