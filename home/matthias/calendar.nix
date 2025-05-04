{ config, pkgs, ... }: let
  make-calendar-account = { pass-file, user ? config.home.username, calendar, color, primary ? false }: let
    build-url = pkgs.writeShellScript "build-url" "echo $(pass-get ${pass-file} url-dav)/calendars/${user}/${calendar}/";
  in {
    inherit primary;

    local.type = "filesystem";
    local.fileExt = ".icf";

    remote.type = "caldav";
    vdirsyncer.urlCommand = [ build-url.outPath ];
    vdirsyncer.userNameCommand = [ "pass-get" pass-file "user" ];
    remote.passwordCommand = [ "pass-get" pass-file ];

    vdirsyncer = {
      enable = true;
      conflictResolution = "remote wins";
    };

    khal = {
      enable = true;
      type = "calendar";
      color = color;
    };
  };
in {
  programs.khal = {
    enable = true;
    settings = {
      default = {
        default_calendar = "personal";
        timedelta = "7d";
      };
    };
  };
  programs.vdirsyncer.enable = true;
  services.vdirsyncer.enable = true;

  accounts.calendar.basePath = ".calendar";

  accounts.calendar.accounts."personal" = make-calendar-account{
    pass-file = "Cloud/richter.band";
    calendar = "personal";
    color = "2";
    primary = true;
  };

  accounts.calendar.accounts."familienkalender" = make-calendar-account{
    pass-file = "Cloud/richter.band";
    calendar = "familienkalender";
    color = "1";
  };
}
