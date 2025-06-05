{
  pkgs,
  lib,
  ...
}: let
  swww = lib.getExe' pkgs.swww "swww";
  systemd-target.session = "graphical-session.target";
  change-wallpaper = pkgs.writeShellScriptBin "change-wallpaper" ''
    [[ -d ~/Wallpaper ]] || exit 1
    img="$(find ~/Wallpaper | shuf | head -1)"
    ${swww} img "$img" --transition-step 3 --transition-fps 60
  '';
in {

  home.packages = [
    pkgs.swww
    change-wallpaper
  ];

  systemd.user.services = {
    swww = {
      Install = { WantedBy = [ systemd-target.session ]; };

      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "swww-daemon";
        PartOf = [ systemd-target.session ];
      };

      Service = {
        ExecStart = lib.getExe' pkgs.swww "swww-daemon";
        Restart = "always";
        RestartSec = 10;
      };
    };

    change-wallpaper = {
      Install = { WantedBy = [ systemd-target.session ]; };

      Unit = {
        Description = "Change to a random wallpaper";
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe' change-wallpaper "change-wallpaper";
      };
    };
  };

  systemd.user.timers.change-wallpaper = {
    Unit.Description = "Periodically change to a random wallpaper";
    Timer = { OnBootSec = "15min"; OnUnitActiveSec = "1h"; };
    Install.WantedBy = [ "timers.target" ];
  };

}
