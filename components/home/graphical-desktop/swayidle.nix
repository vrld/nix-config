{
  pkgs,
  lib,
  config,
  ...
}: let
  loginctl = lib.getExe' pkgs.systemd "loginctl";
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  playerctl-bin = lib.getExe' config.services.playerctld.package "playerctl";
in{
  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${loginctl} lock-session"; }
      { event = "lock"; command = "${playerctl-bin} pause"; }
    ];
    timeouts = [
      { timeout = 600; command = "${loginctl} lock-session"; }
      { timeout = 1800; command = "${systemctl} suspend"; }
    ];
  };

}
