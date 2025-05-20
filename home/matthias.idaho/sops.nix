{
  lib,
  inputs,
  config,
  ...
}: let
  homeDirectory = config.home.homeDirectory;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = false;

    secrets = {
      "ssh-keys/ed25519" = {
        path = "${homeDirectory}/.ssh/id_ed25519";
        mode = "0400";
      };
      "ssh-keys/ecdsa" = {
        path = "${homeDirectory}/.ssh/id_ecdsa";
        mode = "0400";
      };
      "when-calendar".path = "${homeDirectory}/.when/calendar";
      "api-keys" = {};
    };
  };

  home.sessionVariablesExtra = lib.mkMerge [
    "source ${config.sops.secrets."api-keys".path}"
  ];
}
