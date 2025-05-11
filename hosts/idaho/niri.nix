{ pkgs, lib, ... }: {

  # programs.niri.enable = true does not configure it the way I want to,
  # so here we go

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    niri
    xwayland-satellite
    nautilus
  ];

  # see:
  # nixpgs:nixos/modules/programs/wayland/niri.nix
  # nixpgs:nixos/modules/programs/wayland/wayland-session.nix
  services.displayManager.sessionPackages = [ pkgs.niri ];
  services.gnome.gnome-keyring.enable = true;
  systemd.packages = [ pkgs.niri ];
  programs.dconf.enable = true;
  services.graphical-desktop.enable = true;
  programs.xwayland.enable = true;
  services.xserver.desktopManager.runXdgAutostartIfNone = lib.mkDefault true;

  xdg.portal = {
    enable = true;
    configPackages = [ pkgs.niri ];
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  # required for file chooser portal
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty";
  };
  services.gnome.sushi.enable = true;

  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  services.xserver.displayManager.gdm.enable = true;
  security.polkit.enable = true;
  security.pam.services.swaylock = {};

}
