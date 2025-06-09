{
  config,
  pkgs,
  lib,
  ...
}: let
  notmuch = lib.getExe' pkgs.notmuch "notmuch";
  notify-send = lib.getExe' pkgs.libnotify "notify-send";
  xargs = lib.getExe' pkgs.findutils "xargs";
  rm = lib.getExe' pkgs.coreutils "rm";

  # NOTE: builtins.split "@" "name@host.tld" = ["name" [...] "host.tld"]
  hostname-from-address = address: builtins.elemAt (builtins.split "@" address) 2;

  account-defaults = {
    realName = "Matthias Richter";

    notmuch.enable = true;
  };

  make-tutnix-account = {
    address,
    aliases ? [],
    primary ? false,
  }: let
    hostname = hostname-from-address address;
  in lib.recursiveUpdate account-defaults {

    primary = primary;
    address = address;
    aliases = aliases;
    userName = address;
    passwordCommand = "pass-get Mail/${hostname}";

    imap = { host = "tutnix.dev"; port = 993; };
    mbsync = { enable = true; create = "maildir"; expunge = "both"; };
    smtp = { host = "tutnix.dev"; port = 465; };
    msmtp.enable = true;
  };

in {
  # TODO: gpg - sign by default
  accounts.email.maildirBasePath = "Mail";

  accounts.email.accounts."vrld.org" = make-tutnix-account {
    primary = true;
    address = "matthias@vrld.org";
    aliases = [ "mrichter@vrld.org" "vrld@vrld.org" "postmaster@vrld.org" "abuse@vrld.org" ];
  };

  accounts.email.accounts."tutnix.dev" = make-tutnix-account {
    address = "matthias@tutnix.dev";
    aliases = [  "postmaster@tutnix.dev" "abuse@tutnix.dev" ];
  };

  accounts.email.accounts."richter.band" = make-tutnix-account {
    address = "matthias@richter.band";
    aliases = [  "postmaster@richter.band" "abuse@richter.band" ];
  };

  accounts.email.accounts."gmail.com" = let
    address = "to.vrld@gmail.com";
  in lib.recursiveUpdate account-defaults {
    flavor = "gmail.com";
    address = address;
    userName = address;
    passwordCommand = "pass-get Mail/gmail.com";

    imap.host = "imap.gmail.com";

    # NOTE: lieer needs additional setup:
    #
    # 1. create expected mail directories under this account:
    #
    #    $ mkdir ~/Mail/gmail.com/mail/{cur,tmp,new}
    #
    # 2. complete authentication flow:
    #
    #    $ cd ~/Mail/gmail.com && gmi auth
    lieer = {
      enable = true;  # generates config file, but does *not* enable synchronization, obviously
      sync.enable = true;  # ... this does
      settings = {
        drop_non_existing_label = true;
        local_trash_tag = "deleted";
      };
    };

    smtp.host = "smtp.gmail.com";
    msmtp.enable = true;
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  services.lieer.enable = true;

  programs.notmuch = {
    enable = true;
    search.excludeTags = [ "deleted" ];
    new.tags = [ "new" ];
    maildir.synchronizeFlags = true;
    extraConfig.query = {
      "INBOX" = "tag:unread or tag:inbox";
      "Recent" = "date:2w..";
      "Quarter" = "date:3mo..";
      "Year" = "date:1y..";
    };
    hooks = {
      preNew = ''
        ${notmuch} search --output=files --format=text0 tag:deleted | ${xargs} -r0 ${rm}
        mbsync -a
      '';
      postNew = ''
        COUNT_NEW=$(${notmuch} count tag:new)
        test "$COUNT_NEW" -eq 0 && exit 0

        # auto archive old messages
        ${notmuch} tag +archive -inbox "tag:inbox and not (tag:unread or tag:TODO or tag:flagged) and date:..4w"

        # don't put these into the inbox
        ${notmuch} tag +spam -new -- tag:new and folder:/Spam/
        ${notmuch} tag +sent -new -- tag:new and folder:/Sent/

        # flag mail admin related addresses
        ${notmuch} tag +abuse +flagged -- "tag:new and (to:abuse@vrld.org or to:abuse@tutnix.dev or to:abuse@richter.band)"
        ${notmuch} tag +postmaster +flagged -- "tag:new and (to:postmaster@vrld.org or to:postmaster@tutnix.dev or to:postmaster@richter.band)"

        # finish processing
        ${notmuch} tag +inbox +unread -new -- tag:new

        COUNT_UNREAD=$(${notmuch} count tag:unread)
        ${notify-send} -u normal -a notmuch "Post ist da!" "$COUNT_NEW neu\n$COUNT_UNREAD ungelesen"
      '';
    };
  };

  systemd.user.services.notmuch-new = {
    Install = { WantedBy = [ "default.target" ]; };

    Unit.Description = "Look for new mail";
    Service = {
      Type = "oneshot";
      ExecStart = "${notmuch} new";
    };
  };

  systemd.user.timers.notmuch-new = {
    Unit.Description = "Periodically look for new mail";
    Timer = { OnStartupSec = "23"; OnUnitInactiveSec = "15min"; };
    Install.WantedBy = [ "timers.target" ];
  };

}
