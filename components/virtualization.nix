{ pkgs, lib, ... }: {

  # ref: https://discourse.nixos.org/t/rootless-podman-setup-with-home-manager/57905

  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [
    podman
  ];

  users.groups.podman.name = "podman";

  # Add 'newuidmap' and 'sh' to the PATH for users' Systemd units.
  # Required for Rootless podman.
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [ pkgs.bash ]}"
  '';

}
