{...}: {
  programs.khal.enable = true;
  programs.khard.enable = true;
  programs.vdirsyncer.enable = true;
  services.vdirsyncer.enable = true;

  accounts.contact.basePath = ".contacts";

  accounts.contact.accounts."stilgar" = {
    local.type = "filesystem";
    local.fileExt = ".vcf";

    remote.type = "carddav";
    vdirsyncer.urlCommand = [ "pass-get" "Cloud/tutnix.dev" "url-dav" ];
    vdirsyncer.userNameCommand = [ "pass-get" "Cloud/tutnix.dev" "user" ];
    remote.passwordCommand = [ "pass-get" "Cloud/tutnix.dev" ];

    khard = {
      enable = true;
      defaultCollection = "contacts";
    };

    khal = {
      enable = true;
      collections = [ "contacts" ];
      readOnly = true;
      color = "light blue";
    };

    vdirsyncer = {
      enable = true;
      conflictResolution = "remote wins";
      collections = [ "contacts" ];
    };
  };
}
