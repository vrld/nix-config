{

  security.acme = {
    acceptTerms = true;
    defaults.webroot = "/var/lib/acme/acme-challenge";
    defaults.email = "matthias-acme@vrld.org";

    certs = {
      "tutnix.dev" = {
        extraDomainNames = [
          "www.tutnix.dev"
          "mx.tutnix.dev"
          "nc.tutnix.dev"
        ];
        group = "nginx";
      };

      "vrld.org" = {
        extraDomainNames = [ "www.vrld.org" ];
        group = "nginx";
      };

      "ncoder.eu" = {
        extraDomainNames = [ "www.ncoder.eu" ];
        group = "nginx";
      };

      "karlsruhe.ai" = {
        extraDomainNames = [ "www.karlsruhe.ai" ];
        group = "nginx";
      };

    };

  };

}
