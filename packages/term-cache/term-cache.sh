die() {
  echo "$2"
  exit "$1"
}

usage() {
  script=$(basename "$0")
  cat <<EOF
${script} (f|r|u|i) [query/term]

Record and query usage of terms, e.g., for pre-sorting entries in fzf.
'query' supports SQL placeholders: % for any number of matches, _ for exactly one match

Environment:

  TERM_USAGE_DB  Path to the sqlite database; must be set, or the script will fail.

Commands:

  ${script} (u|use) (term): Record the usage of a term.

    e.g.: ${script} u firefox

  ${script} (i|init): Initialize terms with usage count 0 from stdin; each term
                      must be on a new line

    e.g.: fd | ${script} i


  ${script} (f|frequent) [query]: List terms sorted by number of usage counts,
                                  optionally restricted to terms matching 'query'

    e.g.: ${script} f
          ${script} f "assets:%"


  ${script} (r|recent) [query]: List terms sorted by last usage, optionally
                                restricted to terms matching 'query'

    e.g.: ${script} r
          ${script} r "expenses:%"
EOF

  test $# -gt 0 && exit "$1" || exit 0
}

test $# -gt 0 || usage 0

command="$1"
case ${command} in
  ''|h|help|-h|--help) usage 0
esac

test -z "${TERM_USAGE_DB}" && die 1 "Environment variable TERM_USAGE_DB not set"

query() {
  sqlite3 -batch -list -noheader "${TERM_USAGE_DB}" "$@"
}

query "CREATE TABLE IF NOT EXISTS cache (str text PRIMARY KEY, count int DEFAULT 0, last_update text DEFAULT '')"
rest=""
if test $# -gt 1; then
  shift
  rest=$(echo -n "$@" | sed "s/'/\\\\'/")
fi

where=""
if test -n "$rest"; then
  where="WHERE str LIKE '${rest}'"
fi

case ${command} in
  u|use)
    test -n "${rest}" || die 2 "No term given"
    query "INSERT INTO cache VALUES ('${rest}', 1, datetime('now')) ON CONFLICT (str) DO UPDATE SET count = count + 1, last_update = datetime('now')"
    ;;
  f|frequent)
    query "SELECT str FROM cache ${where} ORDER BY count DESC"
    ;;
  r|recent)
    query "SELECT str FROM cache ${where} ORDER BY last_update DESC"
    ;;
  i|init)
    values=$(awk "{printf \"%s('%s')\", sep, \$0; sep=\",\"}")
    query "INSERT INTO cache (str) VALUES ${values} ON CONFLICT (str) DO UPDATE SET count = count"
    ;;
  *)
    usage 255
    ;;
esac
