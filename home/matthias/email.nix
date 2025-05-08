{ config, pkgs, lib, ... }: let
  mbsync = lib.getExe' config.programs.mbsync.package "mbsync";
  notmuch = lib.getExe' pkgs.notmuch "notmuch";
  notify-send = lib.getExe' pkgs.libnotify "notify-send";
  pass-get = "${config.home.homeDirectory}/.bin/pass-get";

  # NOTE: builtins.split "@" "name@host.tld" = ["name" [...] "host.tld"]
  hostname-from-address = address: builtins.elemAt (builtins.split "@" address) 2;

  account-defaults = {
    realName = "Matthias Richter";

    notmuch.enable = true;

    imapnotify = {
      enable = true;
      boxes = [ "INBOX" ];
      onNotifyPost = onNewMail.outPath;
    };
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
    passwordCommand = "${pass-get} Mail/${hostname}";

    imap = { host = "tutnix.dev"; port = 993; };
    mbsync = { enable = true; create = "maildir"; expunge = "both"; };
    smtp = { host = "tutnix.dev"; port = 465; };
    msmtp.enable = true;
    imapnotify.onNotify = "${mbsync} ${hostname}:%s";
  };

  onNewMail = pkgs.writeShellScript "notmuch-index-new" ''
    ${notmuch} new
    COUNT_NEW=$(${notmuch} count tag:new)
    test "''${COUNT_NEW}" -eq 0 && exit 0

    notmuch tag +spam -new -- tag:new and folder:/Spam/
    notmuch tag +sent -- tag:new and folder:/Sent/

    notmuch tag +abuse -- "tag:new and (to:abuse@vrld.org or to:abuse@tutnix.dev or to:abuse@richter.band)"
    notmuch tag +postmaster -- "tag:new and (to:postmaster@vrld.org or to:postmaster@tutnix.dev or to:postmaster@richter.band)"

    notmuch tag +inbox +unread -new -- tag:new

    COUNT_UNREAD=$(notmuch count tag:unread)
    ${notify-send} -u normal -a notmuch "Post ist da!" "$COUNT_NEW neu\n$COUNT_UNREAD ungelesen"
  '';
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
    passwordCommand = "${pass-get} Mail/gmail.com";

    imap.host = "imap.gmail.com";

    # TODO: lieer?
    mbsync = {
      enable = true;
      create = "maildir";
      expunge = "both";
      # TODO: figure this out
      groups.gmail.channels = {
        gmail-sent = {
          farPattern = "[Mail]/Sent Mail";
          nearPattern = "Sent";
        };
        gmail-tags = {
          patterns = [ "*" "![Gmail]*" ];
        };
      };
    };

    smtp.host = "smtp.gmail.com";
    msmtp.enable = true;

    imapnotify.onNotify = "${mbsync} gmail.com:%s";
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  services.mbsync = {
    enable = true;
    preExec = "${notmuch} search --output=files --format=text0 tag:deleted | xargs -r0 /bin/rm";
    postExec = onNewMail.outPath;
  };

  services.imapnotify.enable = true;

  programs.notmuch = {
    enable = true;
    search.excludeTags = [ "deleted" ];
    new.tags = [ "unread" "new" ];
  };

}
