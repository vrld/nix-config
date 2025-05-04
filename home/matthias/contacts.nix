{...}: {
  programs.khal.enable = true;
  programs.khard.enable = true;
  programs.vdirsyncer.enable = true;
  services.vdirsyncer.enable = true;

  accounts.contact.basePath = ".contacts";

  accounts.contact.accounts."richter_band" = {
    local.type = "filesystem";
    local.fileExt = ".vcf";

    remote.type = "carddav";
    vdirsyncer.urlCommand = [ "pass-get" "Cloud/richter.band" "url-dav" ];
    vdirsyncer.userNameCommand = [ "pass-get" "Cloud/richter.band" "user" ];
    remote.passwordCommand = [ "pass-get" "Cloud/richter.band" ];

    khard = {
      enable = true;
      defaultCollection = "contacts";
    };

    khal = {
      enable = true;
      collections = [ "contacts" ];
      readOnly = true;
      color = "4";
    };

    vdirsyncer = {
      enable = true;
      conflictResolution = "remote wins";
      collections = [ "contacts" ];
    };
  };
}
