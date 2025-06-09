{config, lib, ...} : {

  mailserver = {
    enable = true;
    openFirewall = true;

    fqdn = "mx.tutnix.dev";
    sendingFqdn = "tutnix.dev";
    domains = [
      "tutnix.dev"
      "vrld.org"
      "karlsruhe.ai"
    ];

    recipientDelimiter = "-";
    lmtpSaveToDetailMailbox = "no";  # "yes" would create mailboxes for every string after the "-", but that messes with mobile clients
    enableManageSieve = true;

    loginAccounts = {
      "matthias@tutnix.dev".hashedPasswordFile = config.sops.templates."postfix-matthias@tutnix.dev".file;
      "matthias@vrld.org".hashedPasswordFile = config.sops.templates."postfix-matthias@vrld.org".file;
    };

    rejectSender = [
      "ds-group.co.uk"
      "info@debriditalia.com"
    ];

    # see ./acme.nix
    certificateScheme = "acme";

    dmarcReporting = {
      enable = true;
      domain = "tutnix.dev";
      organizationName = "just some guy";
    };
  };

  services.postfix = {
    lookupMX = true;
    mapFiles.virtual = lib.mkForce config.sops.templates.postfix-virtual.file;
  };

}
