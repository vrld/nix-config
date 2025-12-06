{
  pkgs,
  lib,
  config,
  ...
}:
let
  swaylock = lib.getExe' config.programs.swaylock.package "swaylock";
  loginctl = lib.getExe' pkgs.systemd "loginctl";
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  playerctl-bin = lib.getExe' config.services.playerctld.package "playerctl";

  my-lock = lib.getExe (
    pkgs.writeShellScriptBin "my-lock" /* bash */ ''
      ${playerctl-bin} pause
      pgrep swaylock >/dev/null || ${swaylock} -f
      exit 0
    ''
  );
in
{
  services.swayidle = {
    enable = true;
    events = {
      "lock" = my-lock;
    };
    timeouts = [
      {
        timeout = 600;
        command = "${loginctl} lock-session";
      }
      {
        timeout = 1800;
        command = "${systemctl} suspend";
      }
    ];
  };

}
