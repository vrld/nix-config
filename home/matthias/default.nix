{
  pkgs,
  ...
}: let
  homeDirectory = "/home/matthias";
in {
  imports = [
    ./email.nix
    # ./neomutt.nix  # XXX: broken
    ./calendar.nix
    ./contacts.nix
    ./zsh.nix
    ./wayland.nix
    ./niri.nix
    ./alacritty.nix
    ./ghostty.nix
    ./firefox.nix
    ./neovim
    ./sops.nix
  ];

  home = {
    inherit homeDirectory;
    username = "matthias";
    preferXdgDirectories = true;
  };

  home.sessionPath = ["$HOME/.bin"];

  home.sessionVariables = {
    #PATH = "$HOME/.bin:$PATH";
    EDITOR = "nvim";
    TERMINAL_EMULATOR = "ghostty";
    JAVA_OPTS = "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel";
  };

  home.packages = with pkgs; [
    home-manager

    when
    (imagemagick.override {
      libX11Support = false;
      libXtSupport = false;
    })

    signal-desktop
    steam
    spotify

    jujutsu
    python312Packages.bugwarrior
    timewarrior
  ];

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.password-store = {
    enable = true;
    settings.PASSWORD_STORE_DIR = "${homeDirectory}/.password-store";
    settings.PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    package = pkgs.pass.withExtensions (p: [ p.pass-otp p.pass-genphrase p.pass-audit ]);
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  #services.yubikey-agent.enable = true;

  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    addKeysToAgent = "ask";
  };

  programs.git = {
    enable = true;
    userName = "Matthias Richter";
    userEmail = "vrld@vrld.org";
    extraConfig = {
      color.branch = "auto";
      color.ui = "auto";
      diff.renamelimit = 0;
      push.default = "matching";
      init.defaultBranch = "main";
    };
    aliases = {
      diffc = "diff --cached";
      co = "checkout";
      ci = "commit";
      st = "status -sb";
      br = "branch -a";
      hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
    };
    ignores = [ "*.swo" "*.swp" ];
  };

  services.udiskie = {
    enable = true;
    automount = false;
    notify = true;
    settings.program_options.terminal = "\${TERMINAL_EMULATOR} --working-directory";
  };

  services.playerctld.enable = true;
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

  home.file.".bin" = {
    source = ./res/bin;
    recursive = true;
    executable = true;
    force = true;
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

  programs.zathura.enable = true;

  programs.spotify-player.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
