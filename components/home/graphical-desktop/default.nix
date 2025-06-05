{
  pkgs,
  ...
}: let

  set-brightness = pkgs.writeShellScriptBin "set-brightness" ''
    WOBSOCK=/run/user/$(id -u)/wob.sock
    [[ -p $WOBSOCK ]] || exit 1

    brightnessctl set $1 | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > $WOBSOCK
  '';

  set-volume = pkgs.writeShellScriptBin "set-volume" ''
    set -ex

    wobwob() {
      WOBSOCK=/run/user/$(id -u)/wob.sock
      test -p $WOBSOCK && echo $1 > $WOBSOCK
    }

    SINK=$1
    ARG=$2

    if test $ARG = "toggle"; then
      wpctl set-mute $SINK $ARG && wobwob 0
      exit
    fi

    wpctl set-volume $SINK $ARG \
      && wobwob $(wpctl get-volume $SINK | cut -d' ' -f2 | tr -d '.')
  '';

in {

  imports = [
    ./chooser.nix
    ./fontconfig.nix
    ./gammastep.nix
    ./mako.nix
    ./swayidle.nix
    ./swaylock.nix
    ./themes.nix
    ./udiskie.nix
    ./wallpapers.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    libnotify
    wdisplays
    wl-clipboard
    brightnessctl
    pavucontrol
    playerctl
    viewnior
    set-brightness
    set-volume
  ];

  programs = {
    mpv.enable = true;
    zathura.enable = true;
  };

  services = {
    gnome-keyring = {
      enable = true;
      components = [ "secrets" "ssh" "pkcs11" ];
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
    kanshi.enable = true;
    network-manager-applet.enable = true;
    playerctld.enable = true;
  };

}
