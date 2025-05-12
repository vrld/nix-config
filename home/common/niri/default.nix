{
  config,
  lib,
  pkgs,
  ...
}: let
  homeDirectory = config.home.homeDirectory;

  systemd-target.session = "graphical-session.target";
  systemd-target.tray = "tray.target";
  systemd-target.niri = "niri.service";
  systemd-target.waybar = "waybar.service";

  niri = lib.getExe' pkgs.niri "niri";
  syncthingtray = lib.getExe' config.services.syncthing.tray.package "syncthingtray";

in {
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  programs.waybar.settings = {
    main-bar = {
      modules-center = [ "niri/window" ];
      "niri/window" = {
        "rewrite" = {
          "(.*) .+Mozilla Firefox" = "$1";
          "(.*) .+Mozilla Firefox (Privater Modus)" = "$1  ";
          "(.*) . vim" = " $1";
          "(.*) . zsh" = "$1";
        };
        "separate-outputs" = true;
        icon = true;
        "icon-size" = 16;
      };
    };
    side-bar = {
      layer = "top";
      position = "left";
      margin-left = 8;
      exclusive = false;
      modules-center = [ "niri/workspaces" ];
      "niri/workspaces" = {
        all-outputs = false;
        format = "{icon}";
        format-icons = {
          focused = "";
          active = "";
          default = "";
        };
      };
    };
  };

  programs.waybar.style = /*css*/''
    window.left box.modules-center {
      border-radius: 40px;
      min-width: 48px;
      padding: 8px 2px;
    }

    #workspaces button {
      background: transparent;
      border: none;
    }

    #workspaces button>label {
      font-size: 28pt;
      transition: color 250ms;
    }

    #workspaces button.active>label {
      color:
        /*#83a598;*/
        rgba(131, 165, 152, .8);
    }

    #workspaces button.empty>label {
      color:
        /*#665c54;*/
        rgba(102, 92, 84, .8);
    }

    #workspaces button:hover>label {
      color: #689d6a;
    }
  '';

  services = {
    swayidle = {
      timeouts = [
        {
          timeout = 300;
          command = "${niri} msg action power-off-monitors";
          resumeCommand = "${niri} msg action power-on-monitors";
        }
      ];
      systemdTarget = systemd-target.session;
    };

    wob = {
      enable = true;
      settings."" = {
        anchor = "bottom";
        width = 1000;
        height = 60;
        margin = 100;
        output_mode = "all";
      };
    };

    blueman-applet.enable = true;
    network-manager-applet.enable = true;
    syncthing.tray.enable = true;

    kanshi.systemdTarget = systemd-target.niri;
  };

  systemd.user.timers.change-wallpaper = {
    Unit.Description = "Periodically change to a random wallpaper";
    Timer = { OnBootSec = "15min"; OnUnitActiveSec = "1h"; };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services = {
    change-wallpaper = {
      Install = { WantedBy = [ systemd-target.session ]; };

      Unit = {
        Description = "Change to a random wallpaper";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        After = [ systemd-target.niri ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${homeDirectory}/.bin/change-wallpaper";
      };
    };

    swww = {
      Install = { WantedBy = [ systemd-target.session ]; };

      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "swww-daemon";
        After = [ systemd-target.niri ];
        PartOf = [ systemd-target.session ];
      };

      Service = {
        ExecStart = lib.getExe' pkgs.swww "swww-daemon";
        Restart = "always";
        RestartSec = 10;
      };
    };

    xwayland-satellite = {
      Install = { WantedBy = [ systemd-target.session ]; };

      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "xwayland-satellite";
        After = [ systemd-target.niri ];
        PartOf = [ systemd-target.session ];
      };

      Service = {
        ExecStart = lib.getExe' pkgs.xwayland-satellite "xwayland-satellite";
        Restart = "always";
        RestartSec = 10;
      };
    };

    # Ensure correct order of services by rewriting the dependency graph
    swayidle = {
      Unit.After = lib.mkForce [ systemd-target.niri ];
      Install.WantedBy = lib.mkForce [ systemd-target.session ];
    };

    kanshi = {
      Unit.After = lib.mkForce [ systemd-target.niri ];
      Install.WantedBy = lib.mkForce [ systemd-target.session ];
    };

    wob = {
      Unit.After = lib.mkForce [ systemd-target.niri ];
      Install.WantedBy = lib.mkForce [ systemd-target.session ];
    };

    # tray
    waybar = lib.optionalAttrs config.programs.waybar.enable {
      Unit = {
        After = lib.mkForce [ systemd-target.niri ];
        Before = lib.mkForce [ systemd-target.tray ];
      };
      Install.WantedBy = lib.mkForce [ systemd-target.session ];
    };

    blueman-applet.Install.WantedBy = lib.mkForce [ systemd-target.tray ];

    network-manager-applet.Install.WantedBy = lib.mkForce [ systemd-target.tray ];

    nextcloud-client = {
      Install.WantedBy = lib.mkForce [ systemd-target.tray ];
      Unit.After = lib.mkForce [ systemd-target.waybar ];
    };

    ${config.services.syncthing.tray.package.pname} = {
      Install.WantedBy = lib.mkForce [ systemd-target.tray ];
      Unit.After = lib.mkForce [ systemd-target.waybar ];
      Service.ExecStart = lib.mkForce "${syncthingtray} --wait";
    };
  };

}
