{ pkgs, config, ... }: {

  services.nginx = {
    enable = true;
    defaultListenAddresses = [ "49.13.59.114" ];

    virtualHosts = {
      "tutnix.dev" = {
        default = true;
        forceSSL = true;
        useACMEHost = "tutnix.dev";
        serverAliases = [ "www.tutnix.dev" ];
        locations."/".root = "/var/www/tutnix.dev";
      };

      "mqtt.tutnix.dev" = {
        locations."/".proxyPass = "http://127.0.0.1:9001";
        locations."/".proxyWebsockets = true;
      };

      "nc.tutnix.dev" = {
        forceSSL = true;
        useACMEHost = "tutnix.dev";
      };

      "vrld.org" = {
        forceSSL = true;
        useACMEHost = "vrld.org";
        serverAliases = [ "www.vrld.org" ];
        locations."/".root = "/var/www/vrld.org";
      };

      "ncoder.eu" = {
        forceSSL = true;
        useACMEHost = "ncoder.eu";
        serverAliases = [ "www.ncoder.eu" ];
        locations."/".root = "/var/www/ncoder.eu";
      };

      "karlsruhe.ai" = {
        forceSSL = true;
        useACMEHost = "karlsruhe.ai";
        serverAliases = [ "www.karlsruhe.ai" ];
        locations."/" = { root = "/var/www/karlsruhe.ai"; };
      };
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "nc.tutnix.dev";
    https = true;

    appstoreEnable = false;

    database.createLocally = true;

    config = {
      dbtype = "sqlite";
      adminuser = "wurzel";
      adminpassFile = config.sops.secrets."stilgar/nextcloud-admin".path;
    };
    settings.default_phone_region = "DE";

    # see https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/servers/nextcloud/packages/nextcloud-apps.json
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts mail news notes phonetrack tasks;
    };
  };

}
