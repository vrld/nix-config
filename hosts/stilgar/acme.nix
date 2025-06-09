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
        ];
        group = "nginx";
      };

      "vrld.org" = {
        extraDomainNames = [ "www.vrld.org" ];
        group = "nginx";
      };

      "karlsruhe.ai" = {
        extraDomainNames = [ "www.karlsruhe.ai" ];
        group = "nginx";
      };

    };

  };

}
