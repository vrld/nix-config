{ pkgs, ... }:
{

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

}
