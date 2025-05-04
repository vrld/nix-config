{config, pkgs, lib, ...}: let
  mbsync = lib.getExe' config.programs.mbsync.package "mbsync";
  notmuch = lib.getExe' pkgs.notmuch "notmuch";
  notify-send = lib.getExe' pkgs.libnotify "notify-send";
  pass-get = "${config.home.homeDirectory}/.bin/pass-get";

  # NOTE: builtins.split "@" "name@host.tld" = ["name" [...] "host.tld"]
  hostname-from-address = address: builtins.elemAt (builtins.split "@" address) 2;

  account-defaults = {
    realName = "Matthias Richter";

    notmuch = {
      enable = true;
      neomutt.enable = true;
    };

    neomutt.enable = true;

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
    next-profile,
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
    neomutt.extraConfig = ''
      alternates -group ${hostname} '@${hostname}$'
      set status_format="%D[%m] ⟨${hostname}⟩ %> (%P)"
      set compose_format="Mail von ${address} %> (%l)"
      macro index,compose,pager \Ca "<enter-command>source ~/.config/neomutt/${next-profile}<Enter>" "next profile"
    '';
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
    next-profile = "gmail.com";
  };

  accounts.email.accounts."gmail.com" = let
    address = "to.vrld@gmail.com";
    next-profile = "tutnix.dev";
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
    neomutt.extraConfig = ''
      alternates -group gmail.com '@gmail.com$'
      set status_format="%D[%m] ⟨gmail.com⟩ %> (%P)"
      set compose_format="Mail von ${address} %> (%l)"
      macro index,compose,pager \Ca "<enter-command>source ~/.config/neomutt/${next-profile}<Enter>" "next profile"
    '';
  };

  accounts.email.accounts."tutnix.dev" = make-tutnix-account {
    address = "matthias@tutnix.dev";
    aliases = [  "postmaster@tutnix.dev" "abuse@tutnix.dev" ];
    next-profile = "richter.band";
  };

  accounts.email.accounts."richter.band" = make-tutnix-account {
    address = "matthias@richter.band";
    aliases = [  "postmaster@richter.band" "abuse@richter.band" ];
    next-profile = "vrld.org";
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;  # TODO: extra config (?)

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

  programs.neomutt = {
    enable = true;
    sidebar.enable = true;

    binds = [
      { map = [ "pager" "index" ]; key = "["; action = "sidebar-prev"; }
      { map = [ "pager" "index" ]; key = "{"; action = "sidebar-next"; }
      { map = [ "pager" "index" ]; key = "}"; action = "sidebar-open"; }
      { map = [ "pager" "index" ]; key = "+"; action = "entire-thread"; }
      { map = [ "index" ]; key = "<"; action = "vfolder-window-backward"; }
      { map = [ "index" ]; key = ">"; action = "vfolder-window-forward"; }
      { map = [ "index" ]; key = "/"; action = "vfolder-from-query"; }
      { map = [ "pager" "index" ]; key = "t"; action = "modify-labels"; }
    ];

    macros = [
      { map = [ "pager" "index" ]; key = "B"; action = "<enter-command>toggle sidebar_visible<enter><refresh>"; }
      { map = [ "pager" "index" ]; key = "X"; action = "<change-vfolder>?"; }
      { map = [ "index" ]; key = "d"; action = "<modify-tags-then-hide>+deleted<enter>"; }
      { map = [ "index" ]; key = "u"; action = "<modify-tags-then-hide>-deleted<enter>"; }
    ];

    extraConfig = ''
      # unfuck notmuch config
      set nm_exclude_tags = "deleted"
      unmailboxes *
      virtual-mailboxes "Kontext" "notmuch://?query=tag%3Aunread%20or%20date%3A2w..&type=threads"
      virtual-mailboxes "Letzter Monat" "notmuch://?query=date%3A1month..&type=threads"
      virtual-mailboxes "Letztes Quartal" "notmuch://?query=date%3A3month..&type=threads"
      virtual-mailboxes "Archiv" "notmuch://?query=tag%3Aarchive&type=threads"
      virtual-mailboxes "Sent" "notmuch://?query=tag%3Asent&type=threads"
      virtual-mailboxes "Spam" "notmuch://?query=tag%3Aspam&type=threads"
      virtual-mailboxes "Müll" "notmuch://?query=tag%3Adeleted&type=threads"

      set hidden_tags = "inbox";
      set virtual_spoolfile = yes

      # sent mails
      set include=yes  # quote message in reply
      set fast_reply=yes
      set beep=no
      set markers=no
      set confirmappend=no

      # incoming
      ignore *
      unignore Date To From Cc Subject X-Mailer Organization User-Agent
      hdr_order Date To From Cc Subject X-Mailer User-Agent Organization

      # outgoing mails
      set edit_headers=yes
      set attribution="%f:"
      set charset="utf-8"
      set abort_noattach=ask-yes
      set abort_noattach_regex = "\\<(attach|attached|attachments?|angehängt|anhang|anbei|hängt an)\\>"
      set use_from=yes

      # pager
      set pager_context=5        # lines of context when displaying next page
      set pager_index_lines=6    # show a mini-index in pager
      set menu_scroll
      set pgp_verify_sig=no      # dont show pgp in pager
      set status_on_top          # put status line at top
      set sort=threads           # sort by message threads in index
      set sort_aux=last-date-received

      # display
      set date_format="%a, %d. %B %Y"
      set pager_format="%L: %s%* %J %d"
      set index_format="%S%3C %=8@date@ %s %J %* %L"
      index-format-hook date "~d<1d" "%[%H:%M]"
      index-format-hook date "~d<1m" "%[%a, %d.]"
      index-format-hook date "~d<1y" "%[%d. %b]"
      index-format-hook date "~A" "%[%b %Y]"

      tag-transforms "inbox"   "󰚇" \
                     "unread"  "󰇮" \
                     "archive" "󰀼" \
                     "replied" "" \
                     "sent"    "" \
                     "flagged" "" \
                     "deleted" "" \
                     "attachment" "" \
                     "encrypted" "" \
                     "signed" "󰛓" \
                     "spam" ""

      # colors
      color attachment         color6     default
      color hdrdefault         color4     default
      color indicator    bold  color14    default
      color error        bold  color9     default

      color markers      color1     default
      color quoted       color14    default
      color quoted1      color13    default
      color quoted2      color12    default
      color quoted3      color11    default
      color quoted4      color10    default
      color quoted5      color14    default
      color quoted6      color13    default
      color quoted7      color12    default
      color quoted8      color11    default
      color quoted9      color10    default
      color signature    color6     default

      color tilde        color13   default
      color tree         color4    default
      color header       color12   default  ^(Date|From|To|Subject)

      color index_collapsed  color3    default
      color index_author     color12   default  '.*'
      color index_subject    default   default  '.*'
      color index_date       color8    default
      color index_flags      color0    default  '.'
      color index_flags      color3    default  '~U'
      color index_flags      color9    default  '~D'
      color index_number     color7    default
      color index_tags       color7    default

      color status                 color12 default
      color sidebar_divider        color8  default
      color sidebar_ordinary       color8  default
      color sidebar_highlight bold color2  default
      color sidebar_indicator bold default default
      color sidebar_new            color3  default
      color sidebar_unread         color3  default
      color sidebar_flagged        color7  default

    '';
  };
}
