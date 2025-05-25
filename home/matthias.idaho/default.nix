{
  pkgs,
  ...
}: let
  homeDirectory = "/home/matthias";
in {
  imports = [
    ../common
    ./email.nix
    ./neovim-notmuch.nix
    # ./neomutt.nix  # XXX: broken
    ./calendar.nix
    ./contacts.nix
    ./waybar-idaho.nix
    ./firefox.nix
    ./sops.nix
  ];

  home = {
    inherit homeDirectory;
    username = "matthias";
  };

  home.packages = let
    term-cache = import ../../packages/term-cache {inherit pkgs;};
  in with pkgs; [
    when
    (imagemagick.override {
      libX11Support = false;
      libXtSupport = false;
    })

    artisan
    signal-desktop
    steam

    python312Packages.bugwarrior
    timewarrior

    term-cache
  ];

  programs.password-store = {
    enable = true;
    settings.PASSWORD_STORE_DIR = "${homeDirectory}/.password-store";
    settings.PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    package = pkgs.pass.withExtensions (p: [ p.pass-otp p.pass-genphrase p.pass-audit ]);
  };

  #services.yubikey-agent.enable = true;

  programs.git = {
    userName = "Matthias Richter";
    userEmail = "vrld@vrld.org";
  };

  services.nextcloud-client.enable = true;
  services.syncthing.enable = true;

  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = {
      urgency.user.tag = {
        To_Do.coefficient = 10;
        Doing.coefficient = 20;
      };
      purge.on-sync = 1;
      # TODO: sync -- needs taskchampion-sync-server on tutnix.dev
      uda = {
        # Bugwarrior UDAs
        gitlabduedate = { type = "date"; label = "Gitlab Due Date"; };
        gitlaburl = { type = "string"; label = "Gitlab URL"; };
        gitlabweight = { type = "numeric"; label = "Gitlab Weight"; };
        gitlabwip = { type = "numeric"; label = "Gitlab MR Work-In-Progress Flag"; };
        gitlabstate = { type = "string"; label = "Gitlab Issue/MR State"; };
        gitlabauthor = { type = "string"; label = "Gitlab Author"; };
        gitlabassignee = { type = "string"; label = "Gitlab Assignee"; };
        gitlabupdatedat = { type = "date"; label = "Gitlab Updated"; };
        gitlabtype = { type = "string"; label = "Gitlab Type"; };
        gitlabnamespace = { type = "string"; label = "Gitlab Namespace"; };
        gitlabdownvotes = { type = "numeric"; label = "Gitlab Downvotes"; };
        gitlabupvotes = { type = "numeric"; label = "Gitlab Upvotes"; };
        gitlabcreatedon = { type = "date"; label = "Gitlab Created"; };
        gitlabmilestone = { type = "string"; label = "Gitlab Milestone"; };
        gitlabtitle = { type = "string"; label = "Gitlab Title"; };
        gitlabdescription = { type = "string"; label = "Gitlab Description"; };
        gitlabnumber = { type = "numeric"; label = "Gitlab Issue/MR #"; };
        gitlabrepo = { type = "string"; label = "Gitlab Repo Slug"; };
      };
    };
  };

  #services.taskwarrior-sync = {
  #  enable = true;
  #  frequency = "hourly";
  #};

  home.file.".bin/open-html-sanitized" = {
    source = ./bin/open-html-sanitized;
    executable = true;
  };

  home.file.".bin/screencast" = {
    source = ./bin/screencast;
    executable = true;
  };

  home.file.".when/preferences".text = ''
    calendar = ${homeDirectory}/.when/calendar
    editor = nvim
    past = 0
    header = 0
    wrap_auto = 0
    monday_first = y
    language = de
    ampm = 0
  '';

  programs.ledger = {
    enable = true;
    package = pkgs.hledger;
    settings = {
      file = [
        "${homeDirectory}/areas/Finanzen/journal/personal/all.journal"
        "${homeDirectory}/areas/Finanzen/journal/personal.prices"
        "${homeDirectory}/areas/Finanzen/journal/personal.accounts"
      ];
      wide = true;
      color = true;
    };
  };

  services.kanshi.settings = [
    {
      profile.name = "undocked";
      profile.outputs = [
        {
          criteria = "AU Optronics 0x226D Unknown";
          mode = "1920x1080";
          position = "3440,360";
        }
      ];
    }

    {
      profile.name = "docked";
      profile.outputs = [
        {
          criteria = "LG Electronics LG ULTRAWIDE 0x00055D56";
          mode = "3440x1440";
          position = "0,0";
        }
        {
          criteria = "AU Optronics 0x226D Unknown";
          mode = "1920x1080";
          position = "3440,360";
        }
      ];
    }
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
