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

    defaultSopsFile = ../secrets.yaml;
    validateSopsFiles = false;

    secrets = {
      "idaho/matthias/ssh-keys/ed25519".path = "${homeDirectory}/.ssh/id_ed25519";
      "idaho/matthias/ssh-keys/ecdsa".path = "${homeDirectory}/.ssh/id_ecdsa";
      "idaho/matthias/when-calendar".path = "${homeDirectory}/.when/calendar";
      "idaho/matthias/api-keys" = {};
    };
  };

  home.sessionVariablesExtra = lib.mkMerge [
    "source ${config.sops.secrets."idaho/matthias/api-keys".path}"
  ];
}
