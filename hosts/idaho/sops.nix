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
  };

  users = {
    users.matthias.hashedPasswordFile = config.sops.secrets."passwords/matthias".path;
    users.matthias.initialPassword = pkgs.lib.mkForce null;
    mutableUsers = pkgs.lib.mkForce false;
  };

}
