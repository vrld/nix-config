{

  services.gammastep = {
    enable = false;
    provider = "geoclue2";
    temperature = {
      day = 6900;
      night = 4600;
    };
    latitude = 50;
    longitude = 10;
    settings.general.adjustment-method = "wayland";
  };

}
