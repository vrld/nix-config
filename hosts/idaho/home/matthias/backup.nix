{
  pkgs,
  lib,
  config,
  ...
}:
let
  paths-to-backup = lib.getExe (
    pkgs.writeShellScriptBin "paths-to-backup" /* bash */ ''
      cat ${config.sops.secrets."backup/paths".path}
    ''
  );

  backup-init = pkgs.writeShellScriptBin "backup-init" /* bash */ ''
    env $(cat ${config.sops.secrets."backup/env".path}) \
      ${lib.getExe config.services.restic.backups.archive.package} \
        --repository-file ${config.sops.secrets."backup/repository".path} \
        --password-file ${config.sops.secrets."backup/password".path} \
        init
  '';

  backup-restore = pkgs.writeShellScriptBin "backup-restore" /* bash */ ''
    env $(cat ${config.sops.secrets."backup/env".path}) \
      ${lib.getExe config.services.restic.backups.archive.package} \
        --repository-file ${config.sops.secrets."backup/repository".path} \
        --password-file ${config.sops.secrets."backup/password".path} \
        -o s3.enable-restore=1 \
        -o s3.restore-days=3 \
        -o s3.restore-timeout=24h \
        restore latest --target /
  '';
in
{

  services.restic = {
    enable = true;
    backups.archive = {
      repositoryFile = config.sops.secrets."backup/repository".path;
      environmentFile = config.sops.secrets."backup/env".path;
      passwordFile = config.sops.secrets."backup/password".path;
      dynamicFilesFrom = paths-to-backup;
      extraOptions = [
        "s3.store-class=GLACIER"
      ];
      inhibitsSleep = true;
      timerConfig = {
        OnCalendar = "monthly";
        Persistent = true;
      };
    };
  };

  home.packages = [
    backup-init
    backup-restore
  ];

}
