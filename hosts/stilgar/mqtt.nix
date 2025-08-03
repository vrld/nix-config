{ config, ... }:
{

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        users = {

          monitor = {
            acl = [ "read #" ];
            hashedPasswordFile = config.sops.secrets."stilgar/mqtt-monitor".path;
          };

          hochleuchte = {
            acl = [ "readwrite hochleuchte/#" ];
            hashedPasswordFile = config.sops.secrets."stilgar/mqtt-hochleuchte".path;
          };

          valetudo = {
            acl = [ "readwrite valetudo/#" ];
            hashedPasswordFile = config.sops.secrets."stilgar/mqtt-valetudo".path;
          };

        };
      }

      {
        port = 9001;
        users.monitor = {
          acl = [ "read #" ];
          hashedPasswordFile = config.sops.secrets."stilgar/mqtt-monitor".path;
        };
      }
    ];
  };

}
