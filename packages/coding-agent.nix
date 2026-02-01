{ pkgs }:
let
  agent-packages = pkgs.symlinkJoin {
    name = "agent-packages";
    paths = with pkgs; [
      python313
      uv
      go
      gopls
      go-tools
      go-task
      coreutils
      findutils
      gnugrep
      gnused
      bashInteractive
    ];
  };

  image = pkgs.dockerTools.streamLayeredImage {
    name = image-name;
    tag = image-tag;
    architecture = if pkgs.stdenv.isAarch64 then "arm64" else "amd64";

    contents = [
      agent-packages
      pkgs.opencode
    ];

    config = {
      Cmd = [ "/bin/opencode" ];
      WorkingDir = "/home/agent/workspace";
      Env = [
        "PATH=${agent-packages}/bin"
        "PYTHONUNBUFFERED=1"
        "HOME=/home/agent"
        "TMPDIR=/tmp"
        "USER=agent"
        "XDG_CONFIG_HOME=/home/agent/.config"
        "XDG_CACHE_HOME=/home/agent/.cache"
        "XDG_DATA_HOME=/home/agent/.local/share"
      ];
    };
  };

  image-name = "coding-agent";
  image-tag = "latest";

  scripts = {
    manage = pkgs.writeShellScriptBin "coding-agent-manage" ''
      set -euo pipefail
      case "$1" in
        load|l)
          if ! docker image inspect ${image-name}:${image-tag} &>/dev/null; then
            ${image} | docker image load
          fi
          ;;
        reload|r)
          $0 delete
          $0 load
          ;;
        delete|d)
          docker image rm -f coding-agent:latest
          ;;
        *)
          echo "USAGE: $0 [command]"
          echo
          echo "Commands:"
          echo "    load    load the image"
          echo "    delete  delete the image"
          echo "    reload  delete, then load the image"
      esac
    '';

    run = pkgs.writeShellScriptBin "coding-agent" ''
      set -euo pipefail

      ${scripts.manage}/bin/coding-agent-manage load

      exec docker run \
        --rm \
        -v "$(pwd):/home/agent/workspace:rw" \
        -v "$HOME/.config/opencode:/home/agent/.config/opencode:ro" \
        -v "$HOME/.local/share/opencode:/home/agent/.local/share/opencode:rw" \
        -v "$HOME/.local/state/opencode:/home/agent/.local/state/opencode:rw" \
        -v "$HOME/.cache/opencode:/home/agent/.cache/opencode:rw" \
        --security-opt=no-new-privileges \
        --tmpfs /tmp:rw,exec,nosuid,size=256m \
        -it \
        ${image-name}:${image-tag} "$@"
    '';
  };
in
pkgs.symlinkJoin {
  name = "coding-agent";
  paths = [
    scripts.manage
    scripts.run
  ];
}
