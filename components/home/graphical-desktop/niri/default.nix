{
  config,
  lib,
  pkgs,
  ...
}: let
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

  imports = [ ../. ];

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

    window#waybar.empty box.modules-center {
      background: rgba(0, 0, 0, 0);
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

    kanshi.systemdTarget = systemd-target.niri;
  };

  systemd.user.services = {
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

    swww.Unit.After = lib.mkForce [ systemd-target.niri ];
    change-wallpaper.Unit.After = lib.mkForce [ systemd-target.niri ];

    # tray
    waybar = {
      Unit = {
        After = lib.mkForce [ systemd-target.niri ];
        Before = lib.mkForce [ systemd-target.tray ];
      };
      Install.WantedBy = lib.mkForce [ systemd-target.session ];
    };

    blueman-applet.Install.WantedBy = lib.mkForce [ systemd-target.tray ];

    network-manager-applet.Install.WantedBy = lib.mkForce [ systemd-target.tray ];

    nextcloud-client = lib.optionalAttrs config.services.nextcloud-client.enable {
      Install.WantedBy = lib.mkForce [ systemd-target.tray ];
      Unit.After = lib.mkForce [ systemd-target.waybar ];
    };

    ${config.services.syncthing.tray.package.pname} = lib.optionalAttrs config.services.syncthing.enable {
      Install.WantedBy = lib.mkForce [ systemd-target.tray ];
      Unit.After = lib.mkForce [ systemd-target.waybar ];
      Service.ExecStart = lib.mkForce "${syncthingtray} --wait";
    };
  };

}
