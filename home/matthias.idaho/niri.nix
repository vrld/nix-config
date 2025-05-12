{ config, lib, pkgs, ... }: let
  homeDirectory = config.home.homeDirectory;

  systemd-target.session = "graphical-session.target";
  systemd-target.tray = "tray.target";
  systemd-target.niri = "niri.service";
  systemd-target.waybar = "waybar.service";

  niri = lib.getExe' pkgs.niri "niri";
  notmuch = lib.getExe' pkgs.notmuch "notmuch";
  jq = lib.getExe' pkgs.jq "jq";
  khal = lib.getExe' pkgs.khal "khal";
  awk = lib.getExe' pkgs.gawk "awk";
  task = lib.getExe' config.programs.taskwarrior.package "task";
  syncthingtray = lib.getExe' config.services.syncthing.tray.package "syncthingtray";

  widgets.notmuch = pkgs.writeShellScript "waybar-notmuch" ''
    ${notmuch} search --format=json tag:unread | ${jq} -Mc '{
      text: . | length | tostring | ("󰇮 " + .),
      tooltip: map( "<b>" + .authors + "</b>: " + .subject ) | join("\n")
    }'
  '';

  widgets.khal = pkgs.writeShellScript "khal-upcoming" ''
    event_now_or_next=$(${khal} list --once now 15m | ${awk} '/^[^A-Za-z]/{print}')
    count_upcoming=$(${khal} list --once now 1d | ${awk} '/^[^A-Za-z]/{ c = c + 1 } END { print c }')

    tooltip=$(${khal} list | ${awk} '
    BEGIN { OFS="\n" }
    /^[A-Za-z]+, [0-9]{4}-[0-9]{2}-[0-9]{2}$/ {  # dates: add blank line, add <b> tags
        if (date != "") { print "" }             # skip blank line on first date
        date = $0
        print "<b>" date "</b>"
        next
    }
    { print $0 }
    ' | sed ':a;N;$!ba;s/\n/\\n/g')

    echo -n '{"text": "'
    if test -n "$event_now_or_next"; then
      echo -n " $event_now_or_next"
      test "$count_upcoming" -gt 1 && echo -n " [+$(($count_upcoming - 1))]"
    elif test "0$count_upcoming" -gt 0; then
      echo -n " $count_upcoming upcoming"
    else
      echo -n " ‹nix›"
    fi
    echo -n '", "tooltip": "'$tooltip'"}'
  '';

  widgets.tasks = pkgs.writeShellScript "task-open" ''
    ${task} -DELETED -COMPLETED export | ${jq} -Mc '{
      text: . | length | tostring | (" " + .),
      tooltip: map(
          (.priority | if . == "H" then "󰁝 " elif . == "M" then "󰁔 " elif . == "L" then "󰁅 " else "" end) +
          "<b>" + .description + "</b>" +
          (if .recur then " 󰑖" else "" end) +
          (.project | if . then " 󰀼 " + . else "" end) +
          (.tags | if . then " <small>" + (map("󰓹 " + .) | join(" ")) + "</small>" else "" end)
        ) | join("\n")
      }'
  '';

in {
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.configFile."niri/config.kdl".source = ./res/niri/config.kdl;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = builtins.readFile ./res/niri/waybar.css;
    settings = {
      main-bar = {
        layer = "top";
        margin = "8px 10px 4px 10px";
        spacing = 8;

        modules-left = [ "clock" "custom/calendar" "custom/mails" "custom/tasks" ];
        modules-center = [ "niri/window" ];
        modules-right = [ "group/privacy-tools" "group/system-monitor" "group/connectivity" "group/audio" "group/laptop" "tray" ];

        # groups, mainly for styling
        "group/privacy-tools" = {
          orientation = "inherit";
          modules = [ "privacy" "idle_inhibitor" ];
        };

        "group/system-monitor" = {
          orientation = "inherit";
          modules = [ "temperature" "cpu" "memory" "disk" ];
          drawer = {
            transition-left-to-right = false;
            transition-duration = 250;
          };
        };

        "group/connectivity" = {
          orientation = "inherit";
          modules = [ "group/network-detail" "bluetooth" ];
        };

        "group/network-detail" = {
          orientation = "inherit";
          modules = [ "network" "network#bandwidth" ];
          drawer = { transition-duration = 250; };
        };

        "group/laptop" = {
          orientation = "inherit";
          modules = [ "backlight" "battery" ];
        };

        "group/audio" = {
          orientation = "inherit";
          modules = [ "pulseaudio#input" "group/audio-output" ];
        };

        "group/audio-output" = {
          orientation = "inherit";
          modules = [ "pulseaudio#output" "pulseaudio/slider" ];
        };

        # widgets
        "wlr/taskbar" = {
          "on-click" = "activate";
          "icon-theme" = "Arc";
        };

        "niri/window" = {
          "rewrite" = {
            "(.*) .+Mozilla Firefox" = "$1";
            "(.*) .+Mozilla Firefox (Privater Modus)" = "$1  ";
            "(.*) . mpv" = "輸$1";
            "(.*) . vim" = " $1";
            "(.*) . zsh" = "$1";
          };
          "separate-outputs" = true;
          icon = true;
          "icon-size" = 16;
        };

        clock = {
          format = "{:%a %d. %b, %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = { mode = "year"; mode-mon-col = 4; };
        };

        "custom/mails" = {
          format = "{}";
          interval = 300;
          exec = widgets.notmuch.outPath;
          return-type = "json";
          tooltip = true;
          on-click = "\${TERMINAL_EMULATOR} -e neomutt";
        };

        "custom/calendar" = {
          format = "{}";
          interval = 300;
          exec = widgets.khal.outPath;
          on-click = "\${TERMINAL_EMULATOR} -e ikhal";
          return-type = "json";
        };

        "custom/tasks" = {
          format = "{}";
          interval = 300;
          exec = widgets.tasks.outPath;
          on-click = "\${TERMINAL_EMULATOR} -e vim ~/wiki/index.md";
          return-type = "json";
        };

        privacy = {};

        idle_inhibitor = {
          format = "{icon}";
          format-icons = { activated = ""; deactivated = ""; };
        };

        cpu = {
          format = " {usage}%";
          on-click = "\${TERMINAL_EMULATOR} -e htop";
        };

        memory = {
          format = " {percentage}%";
          on-click = "\${TERMINAL_EMULATOR} -e htop";
          tooltip-format = "RAM: {used:0.1f}GiB / {total:0.1f}GiB ({percentage}%)\nSWAP: {swapUsed:0.1f}GiB / {swapTotal:0.1f}GiB ({percentage}%)";
        };

        disk.format = "󰆼 {free}";

        temperature = {
          critical-threshold = 80;
          format = "{icon} {temperatureC}°C";
          format-icons = [ "" "" "" ];
        };
        bluetooth = {
          format-disabled = "󰂲";
          format-off = "󰂲";
          format-on = "󰂯";
          format-connected = "󰂱";
          format-connected-battery = "󰂱 {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          on-click = "blueberry";
        };

        network = {
          format-wifi = "";
          format-ethernet = "󰈁";
          format-linked = "󰈂";
          format-disconnected = "󰈂";
        };

        "network#bandwidth" = {
          format = "{essid}  󰩟 {ipaddr}  󰅧 {bandwidthUpBytes}  󰅢 {bandwidthDownBytes}";
        };

        battery = {
          bat = "BAT0";
          states = {
            warning = 30;
            critical = 15;
          };

          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [ "󱃍" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = [ "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ];
        };

        "pulseaudio#input" = {
          format = "{format_source}";
          format-source = " {volume}%";
          format-source-muted = " ";
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%-";
        };

        "pulseaudio#output" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 ";
          format-bluetooth = "{icon}󰂰 {volume}%";
          format-bluetooth-muted = "󰝟󰂰 ";
          format-icons = {
            default = "󰕾";
            hands-free = "󰋎";
            headset = "󰋎";
          };

          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
        };

        "pulseaudio/slider" = { };

        tray = {
          icon-size = 20;
          spacing = 10;
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
  };

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
  };

  #systemd.user.targets.tray = {
  #  Unit = {
  #    Description = "Target for apps that want to start minimized to the system tray";
  #    After = [ systemd-target.niri ];
  #  };
  #  Install = {
  #    WantedBy = [ systemd-target.session ];
  #  };
  #};

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
      Unit = {
        After = lib.mkForce [ systemd-target.niri ];
        # those are set to sway for some reason
        PartOf = lib.mkForce [ systemd-target.niri ];
        Requires = lib.mkForce [ systemd-target.niri ];
      };
      Install.WantedBy = lib.mkForce [ systemd-target.session ];
    };

    wob = {
      Unit.After = lib.mkForce [ systemd-target.niri ];
      Install.WantedBy = lib.mkForce [ systemd-target.session ];
    };

    # tray
    waybar = {
      Unit = {
        After = lib.mkForce [ systemd-target.niri ];
        Before = lib.mkForce [ systemd-target.tray ];
      };
      Install.WantedBy = lib.mkForce [ systemd-target.session ];
    };

    blueman-applet = {
      Install.WantedBy = lib.mkForce [ systemd-target.tray ];
    };

    network-manager-applet = {
      Install.WantedBy = lib.mkForce [ systemd-target.tray ];
    };

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
