{
  inputs,
  pkgs,
  config,
  ...
}: {

  imports = [
    inputs.sops-nix-stable.nixosModules.sops
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

    secrets."stilgar/mqtt-monitor".restartUnits = ["mosquitto.service"];
    secrets."stilgar/mqtt-maischemeter".restartUnits = ["mosquitto.service"];
    secrets."stilgar/mqtt-hochleuchte".restartUnits = ["mosquitto.service"];
    secrets."stilgar/mqtt-valetudo".restartUnits = ["mosquitto.service"];

    secrets."stilgar/nextcloud-admin" = {
      mode = "0440";
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

  users = {
    users.matthias.hashedPasswordFile = config.sops.secrets."passwords/matthias".path;
    users.matthias.initialPassword = pkgs.lib.mkForce null;
    mutableUsers = pkgs.lib.mkForce false;
  };

}
