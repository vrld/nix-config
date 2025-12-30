{

  security.acme = {
    acceptTerms = true;
    defaults = {
      webroot = "/var/lib/acme/acme-challenge";
      email = "matthias-acme@vrld.org";
      group = "nginx";
    };

    certs = {
      "tutnix.dev" = {
        extraDomainNames = [
          "www.tutnix.dev"
          "mx.tutnix.dev"
          "nc.tutnix.dev"
        ];
      };

      "vrld.org" = {
        extraDomainNames = [ "www.vrld.org" ];
      };

      "ncoder.eu" = {
        extraDomainNames = [ "www.ncoder.eu" ];
      };

      "karlsruhe.ai" = {
        extraDomainNames = [ "www.karlsruhe.ai" ];
      };

    };

  };

}
