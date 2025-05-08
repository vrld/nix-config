{
  config,
  pkgs,
  lib,
  ...
}: let
  loginctl = lib.getExe' pkgs.systemd "loginctl";
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  swaylock-bin = lib.getExe' config.programs.swaylock.package "swaylock";
  playerctl-bin = lib.getExe' config.services.playerctld.package "playerctl";
in {
  home.packages = with pkgs; [
    libnotify
    pavucontrol
    swww
    wdisplays
    wl-clipboard
    playerctl
    brightnessctl
    viewnior
    numix-cursor-theme
  ];

  programs.mpv.enable = true;

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "ssh" "pkcs11" ];
  };

  services.gammastep = {
    enable = false;
    provider = "geoclue2";
    temperature = {
      day = 6900;
      night = 4600;
    };
    latitude = 50;
    longitude = 10;
    settings.general.adjustment-method = "wayland";
  };

  services.mako = {
    enable = true;

    settings = {
      default-timeout = 5000;

      border-size = 4;
      border-radius = 8;
      padding = "12";

      font = "Hack Nerd Font";
      background-color = "#000000DF";
      text-color = "#EBDBB2FF";
      border-color = "#0766788F";
      progress-color = "over #C87F79FF";
    };

    criteria."urgency=critical" = {
      border-color = "#CC241DFF";
      background-color = "#EBDBB2";
      text-color = "#202020";
      default-timeout = 0;
    };
  };

  services.kanshi = {
    enable = true;
    settings = [

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
  };

  services.swayidle = {
    enable = true;
    events = [
      #{ event = "before-sleep"; command = "${loginctl} lock-session"; }
      { event = "lock"; command = swaylock-bin; }
      { event = "lock"; command = "${playerctl-bin} pause"; }
    ];
    timeouts = [
      { timeout = 600; command = "${loginctl} lock-session"; }
      { timeout = 1800; command = "${systemctl} suspend"; }
    ];
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      ignore-empty-password = true;
      show-keyboard-layout = true;
      show-failed-attempts = true;
      grace = 30;
      screenshot = true;
      clock = true;
      indicator = true;
      indicator-radius = 128;
      indicator-thickness = 24;
      effect-pixelate = 64;
    };
  };

  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  home.pointerCursor = {
    package = pkgs.quintom-cursor-theme;
    # name = "Quintom_Ink";
    name = "Quintom_Snow";
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.qogir-theme;
      name = "Qogir-Dark";
    };
    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir-Dark";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style = {
      package = pkgs.qogir-kde;
      name = "QogirDark";  # this is an env var -- how to set this in a script?
    };
  };
}
