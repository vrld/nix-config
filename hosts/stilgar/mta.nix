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
      "matthias@tutnix.dev".hashedPasswordFile = config.sops.secrets."stilgar/postfix-matthias@tutnix.dev".path;
      "matthias@vrld.org".hashedPasswordFile = config.sops.secrets."stilgar/postfix-matthias@vrld.org".path;
    };

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
    mapFiles.virtual = lib.mkForce config.sops.secrets."stilgar/postfix-virtual".path;
    mapFiles.valias = lib.mkForce config.sops.secrets."stilgar/postfix-valias".path;
    mapFiles.vaccounts = lib.mkForce config.sops.secrets."stilgar/postfix-valias".path;
  };

}
