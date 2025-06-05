{ pkgs, lib, ...}: let

  fd = lib.getExe' pkgs.fd "fd";
  fzf = lib.getExe' pkgs.fzf "fzf";
  yad = lib.getExe' pkgs.yad "yad";
  sqlite = lib.getExe' pkgs.sqlite "sqlite3";
  term-cache = pkgs.writeShellScriptBin "term-cache" ''
    die() {
      echo "$2"
      exit "$1"
    }

    usage() {
      cat <<EOF
    term-cache (f|r|u|i) [query/term]

    Record and query usage of terms, e.g., for pre-sorting entries in fzf.
    'query' supports SQL placeholders: % for any number of matches, _ for exactly one match

    Environment:

      TERM_USAGE_DB  Path to the sqlite database; must be set, or the script will fail.

    Commands:

      term-cache (u|use) (term): Record the usage of a term.

        e.g.: term-cache u firefox

      term-cache (i|init): Initialize terms with usage count 0 from stdin; each term
                          must be on a new line

        e.g.: fd | term-cache i


      term-cache (f|frequent) [query]: List terms sorted by number of usage counts,
                                      optionally restricted to terms matching 'query'

        e.g.: term-cache f
              term-cache f "assets:%"


      term-cache (r|recent) [query]: List terms sorted by last usage, optionally
                                    restricted to terms matching 'query'

        e.g.: term-cache r
              term-cache r "expenses:%"
    EOF

      test $# -gt 0 && exit "$1" || exit 0
    }

    test $# -gt 0 || usage 0

    command="$1"
    case "$command" in
      ""|h|help|-h|--help) usage 0
    esac

    test -z "$TERM_USAGE_DB" && die 1 "Environment variable TERM_USAGE_DB not set"

    query() {
      ${sqlite} -batch -list -noheader "$TERM_USAGE_DB" "$@"
    }

    query "CREATE TABLE IF NOT EXISTS cache (str text PRIMARY KEY, count int DEFAULT 0, last_update text)"
    rest=""
    if test $# -gt 1; then
      shift
      rest=$(echo -n "$@" | sed "s/'/\\\\'/")
    fi

    where=""
    if test -n "$rest"; then
      where="WHERE str LIKE '$rest'"
    fi

    case "$command" in
      u|use)
        test -n "$rest" || die 2 "No term given"
        query "INSERT INTO cache VALUES ('$rest', 1, datetime('now')) ON CONFLICT (str) DO UPDATE SET count = count + 1, last_update = datetime('now')"
        ;;
      f|frequent)
        query "SELECT str FROM cache $where ORDER BY count DESC"
        ;;
      r|recent)
        query "SELECT str FROM cache $where ORDER BY last_update DESC"
        ;;
      i|init)
        values=$(awk "{printf \"%s('%s')\", sep, \$0; sep=\",\"}")
        query "INSERT INTO cache (str) VALUES $values ON CONFLICT (str) DO UPDATE SET count = count"
        ;;
      *)
        usage 255
        ;;
    esac
  '';

  fzf-window = pkgs.writeShellScriptBin "fzf-window" ''
    case "$TERMINAL_EMULATOR" in
      alacritty|ghostty)
        $TERMINAL_EMULATOR --class="fzfmenu-$(uuidgen)" --title="fzfmenu" --font-size=18 -e "$1" ;;
      *)
        exit -1;
    esac
  '';

  fzf-menu = pkgs.writeShellScriptBin "fzf-menu" ''
    set -ex

    cachedir=''${XDG_CACHE_HOME:-"$HOME/.cache"}
    db="$cachedir/fzf-menu.db"
    [[ -d "$cachedir" ]] || db="$HOME/.fzf-menu.db"

    # test if we need to update the cache
    IFS=':' read -ra paths <<< "$PATH"
    update_cache=false
    cache_mtime=-1
    [[ -f "$db" ]] && cache_mtime=$(stat -c %Y "$db" 2>/dev/null || echo -1)

    for dir in "''${paths[@]}"; do
      if [[ -d "$dir" && -r "$dir" ]]; then # is readable dir
        dir_mtime=$(stat -c %Y "$dir" 2>/dev/null || echo -1)
        if (( dir_mtime > cache_mtime )); then
          update_cache=true
          break
        fi
      fi
    done

    # list executable files into the cache (basename only)
    if [[ $update_cache == true || ! -f "$db" ]]; then
      fd_args=(--type executable --type symlink --unrestricted --format '{/}')
      for dir in "''${paths[@]}"; do
        [[ -d "$dir" && -r "$dir" ]] && fd_args+=(--search-path "$dir")
      done
      ${fd} "''${fd_args[@]}" 2>/dev/null | sort -u | TERM_USAGE_DB="$db" term-cache init
    fi

    command=$(TERM_USAGE_DB="$db" term-cache frequent | ${fzf} --height=100% +s --reverse --pointer='➤' --prompt='➤ ')
    [[ $? -eq 0 ]] || exit

    TERM_USAGE_DB="$db" term-cache use "$command"
    case $XDG_CURRENT_DESKTOP in
      sway) swaymsg exec "$command" ;;
      niri) niri msg action spawn -- "$command" ;;
      *) notify-send -u critical "Cannot spawn process" "Not a known session type: $XDG_CURRENT_DESKTOP"
    esac
  '';

  # XXX: tight coupling to passwort-store.nix -- hw to resolve?
  fzf-pass = pkgs.writeShellScriptBin "fzf-pass" ''
    function items() {
      ${fd} 'gpg$' ~/.password-store \
        | sed -E 's|^.*/.password-store/(.*)\.gpg$|\1|' \
        | sort
    }

    function menu() {
      ${fzf} --height=100% --pointer='➤' --prompt='➤ ' --reverse
    }

    while true; do
      item=$(items | menu)
      [[ -z "$item" ]] && exit
      item_keys=$(pass-get "$item" -k)
      while true; do
        subitem=$(echo "$item_keys" | menu --header="$item")
        case "$subitem" in
          password)
            pass -c "$item"
            ;;
          *url)
            xdg-open "$(pass-get "$item" "$subitem")"
            ;;
          *misc)
            fn=$(mktemp)
            pass-get "$item" misc > "$fn"
            (${yad} --text-info --filename="$fn"; /bin/rm "$fn") &
            ;;
          *otp*)
            pass otp -c "$item"
            ;;
          "")
            break
            ;;
          *)
            pass-get "$" "$subitem" | wl-copy -n
            ;;
        esac
      done
    done
  '';

  fzf-boot = pkgs.writeShellScriptBin "fzf-boot" ''
    what=$(${fzf} --height=100% --layout=reverse <<EOI
    Lock
    Hibernate
    Reboot
    Shutdown
    EOI
    )

    case "$what" in
      Lock)
        loginctl lock-sessions
        ;;
      Hibernate)
        systemctl hibernate
        ;;
      Reboot)
        systemctl reboot
        ;;
      Shutdown)
        systemctl poweroff
        ;;
    esac
  '';

in {
  home.packages = [
    fzf-window
    fzf-menu
    fzf-pass
    fzf-boot
    term-cache
  ];
}
