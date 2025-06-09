{ pkgs, config, ... }: {

  services.nginx = {
    enable = true;
    defaultListenAddresses = [ "49.13.59.114" ];

    virtualHosts = {
      "tutnix.dev" = {
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
    package = pkgs.nextcloud31;
    hostName = "nc.tutnix.dev";
    https = true;

    #enableImagemagick = false;
    appstoreEnable = false;

    database.createLocally = true;

    config = {
      dbtype = "sqlite";
      adminuser = "wurzel";
      adminpassFile = config.sops.templates.nextcloud-admin.path;
    };
    settings.default_phone_region = "DE";

    #extraApps.news = pkgs.fetchzip rec {
    #  #name = "news";
    #  #version = "22.0.0";
    #  sha256 =  "1lajm39q34iv5bqcvfyvwc3hbi5r91k79l0k0090dgps2dv9f52i";
    #  url = "https://github.com/nextcloud/news/releases/download/22.0.0/news.tar.gz";
    #};

    #extraApps.memories = pkgs.fetchzip rec {
    #  #name = "memories";
    #  #version = "5.2.1";
    #  sha256 =  "02k7l7dq7xqk24l8xmv09lbrwi5dd0apd4vghh40555klj1zq843";
    #  url = "https://github.com/pulsejet/memories/releases/download/v5.2.1/memories.tar.gz";
    #};

    #extraApps.cookbook = pkgs.fetchzip rec {
    #  #name = "cookbook";
    #  #version = "0.10.2";
    #  sha256 =  "08vqc12f88y00a7b3j7qgj8nvx2yc8c8mx8dw4zyv7l1hiw9bchz";
    #  url = "https://github.com/nextcloud/cookbook/releases/download/v0.10.2/Cookbook-0.10.2.tar.gz";
    #};

    #extraApps = with config.services.nextcloud.package.packages.apps; {
    #  inherit calendar contacts;
      # https://apps.nextcloud.com/apps/cookbook
      # https://apps.nextcloud.com/apps/memories
      # https://apps.nextcloud.com/apps/news
    #};
  };

}
