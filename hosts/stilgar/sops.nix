{
  inputs,
  pkgs,
  config,
  ...
}: {

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    age
    sops
  ];

  sops = {
    defaultSopsFile = ../secrets.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets."passwords/matthias".neededForUsers = true;

    secrets."stilgar/postfix-virtual".restartUnits = ["postfix.service"];
    secrets."stilgar/postfix-matthias@tutnix.dev".restartUnits = ["postfix.service"];
    secrets."stilgar/postfix-matthias@vrld.org".restartUnits = ["postfix.service"];
    templates."postfix-virtual".content = config.sops.placeholder."stilgar/postfix-virtual";
    templates."postfix-matthias@tutnix.dev".content = config.sops.placeholder."stilgar/postfix-matthias@tutnix.dev";
    templates."postfix-matthias@vrld.org".content = config.sops.placeholder."stilgar/postfix-matthias@vrld.org";

    secrets."stilgar/mqtt-monitor".restartUnits = ["mosquitto.service"];
    secrets."stilgar/mqtt-maischemeter".restartUnits = ["mosquitto.service"];
    secrets."stilgar/mqtt-hochleuchte".restartUnits = ["mosquitto.service"];
    secrets."stilgar/mqtt-valetudo".restartUnits = ["mosquitto.service"];
    templates."mqtt-monitor".content = config.sops.placeholder."stilgar/mqtt-monitor";
    templates."mqtt-maischemeter".content = config.sops.placeholder."stilgar/mqtt-maischemeter";
    templates."mqtt-hochleuchte".content = config.sops.placeholder."stilgar/mqtt-hochleuchte";
    templates."mqtt-valetudo".content = config.sops.placeholder."stilgar/mqtt-valetudo";

    secrets."stilgar/nextcloud-admin" = {};
    templates."nextcloud-admin".content = config.sops.placeholder."stilgar/nextcloud-admin";
  };

  users = {
    users.matthias.hashedPasswordFile = config.sops.secrets."passwords/matthias".path;
    users.matthias.initialPassword = pkgs.lib.mkForce null;
    mutableUsers = pkgs.lib.mkForce false;
  };

}
