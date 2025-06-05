{
  config,
  pkgs,
  lib,
  ...
}: let
  pass = lib.getExe' pkgs.pass "pass";
  pass-get = pkgs.writeShellScriptBin "pass-get" ''
    usage() {
      echo -e "Usage: $(basename "$0") [-h|--help] PASSNAME [KEY]\n"
      echo "Search secret PASSNAME for an entry KEY and print it"
      echo -e "If KEY is omitted, retrieve the first line instead.\n"
      echo "Options:"
      echo "  -h|--help   Shows this help"
      echo "  -k|--keys   Lists keys of secret PASSNAME"
      return 0
    }

    OPTIONS=$(getopt -o 'hk' -l 'help,keys' -n "$0" -- "$@")
    [[ $? -ne 0 ]] && usage && exit 1
    eval set -- "$OPTIONS"
    unset OPTIONS

    while true; do
      case "$1" in
        '-h'|'--help') usage && exit 0 ;;
        '-k'|'--keys')
          show_keys=yes
          shift
          ;;
        '--')
          shift
          break
          ;;
      esac
    done

    password="$1"
    [[ -z "$password" ]] && exec pass

    # password files look like this:
    # P4ssw0rD!
    # user: lazerh4wk
    # url: https://hawks.are.cool/?login
    # otpauth://...
    # misc:
    # recovery codes
    # random notes
    # PIN: 1234

    if [[ "$show_keys" = "yes" ]]; then
      echo "password"
      ${pass} show "$password" | sed -n '2,''${/^[^:]\+:/{ /^otpauth:/d; s/:.*$//p; }}'
      exit 0
    fi

    key="$2"
    case "$key" in
      ""|"password")
        ${pass} show "$password" | head -n1
        ;;

      *)
        out=$(${pass} show "$password" | sed -n "/^$key:/s/^$key:[[:blank:]]\+//p")
        [[ -n "$out" ]] && echo "$out" && exit 0

        # multiline key
        ${pass} show "$password" | sed -n "/^$key:$/,/^[^:]\+:/{/^$key:$/d; /^[^:]\+:/d; p;}"
        ;;
    esac
  '';
in {

  home.packages = [
    pass-get
  ];

  programs.password-store = {
    enable = true;
    settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
    settings.PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    package = pkgs.pass.withExtensions (p: [ p.pass-otp p.pass-genphrase p.pass-audit ]);
  };

}
