{
  inputs,
  pkgs,
  outputs,
  color-scheme,
  ...
}:
let
  pkgs-stable = import inputs.nixpkgs-stable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
in
{

  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  users = {
    users.matthias = {
      isNormalUser = true;
      description = "Matthias";
      initialPassword = "dreamsmakegoodstories";
      extraGroups = [
        "wheel"
        "networkmanager"
        # virtualization
        "libvirtd"
        "podman"
        # serial devices
        "tty"
        "dialout"
      ];
      openssh.authorizedKeys.keys = [ ];
    };

    defaultUserShell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.matthias = import ./matthias;
    extraSpecialArgs = {
      inherit
        inputs
        outputs
        color-scheme
        pkgs-stable
        ;
    };
  };

  # run unpatched dynamic libraries
  # required for platformmio
  programs.nix-ld.enable = true;

}
