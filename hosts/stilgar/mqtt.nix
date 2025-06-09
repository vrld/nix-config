{ config, ... }:
{

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        users = {

          monitor = {
            acl = [ "read #" ];
            hashedPasswordFile = config.sops.templates."mqtt-monitor".file;
          };

          maischemeter = {
            acl = [ "readwrite maischemeter/#" ];
            hashedPasswordFile = config.sops.templates."mqtt-maischemeter".file;
          };

          hochleuchte = {
            acl = [ "readwrite hochleuchte/#" ];
            hashedPasswordFile = config.sops.templates."mqtt-hochleuchte".file;
          };

          valetudo = {
            acl = [ "readwrite valetudo/#" ];
            hashedPasswordFile = config.sops.templates."mqtt-valetudo".file;
          };

        };
      }

      {
        port = 9001;
        users.monitor = {
          acl = [ "read #" ];
          hashedPasswordFile = config.sops.templates."mqtt-monitor".file;
        };
      }
    ];
  };

}
