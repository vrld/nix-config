{
  pkgs,
  lib,
  config,
  ...
}: {

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

  services.swayidle.events = let
    swaylock = lib.getExe' config.programs.swaylock.package "swaylock";
  in [
    { event = "lock"; command = "pgrep swaylock >/dev/null || ${swaylock}"; }
  ];

}
