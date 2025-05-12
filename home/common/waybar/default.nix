{
  ...
}:{

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = builtins.readFile ./waybar.css;
    settings = {
      main-bar = {
        layer = "top";
        margin = "8px 10px 4px 10px";
        spacing = 8;

        modules-left = [ "clock" ];
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

        clock = {
          format = "{:%a %d. %b, %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = { mode = "year"; mode-mon-col = 4; };
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
    };
  };

}
