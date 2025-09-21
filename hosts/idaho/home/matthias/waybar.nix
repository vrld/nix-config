{
  config,
  pkgs,
  lib,
  ...
}:
let

  notmuch = lib.getExe' pkgs.notmuch "notmuch";
  jq = lib.getExe' pkgs.jq "jq";
  khal = lib.getExe' pkgs.khal "khal";
  awk = lib.getExe' pkgs.gawk "awk";
  task = lib.getExe' config.programs.taskwarrior.package "task";

  widgets.notmuch = pkgs.writeShellScript "waybar-notmuch" ''
    ${notmuch} search --format=json query:INBOX | ${jq} -Mc '{
      text: . | length | tostring | ("󰇮 " + .),
      tooltip: map( "<b>" + (.authors|@html) + "</b>: " + (.subject|@html) ) | join("\n")
    }'
  '';

  widgets.khal = pkgs.writeShellScript "khal-upcoming" ''
    event_now_or_next=$(${khal} list --once now 15m | ${awk} '/^[^A-Za-z]/{print}')
    count_upcoming=$(${khal} list --once now 1d | ${awk} '/^[^A-Za-z]/{ c = c + 1 } END { print c }')

    tooltip=$(${khal} list | ${awk} '
    BEGIN { OFS="\n" }
    /^[A-Za-z]+, [0-9.-]{10}$/ {  # dates: add blank line, add <b> tags
        if (date != "") { print "" }    # skip blank line on first date
        date = $0
        print "<b>" date "</b>"
        next
    }
    { print $0 }
    ' | sed ':a;N;$!ba;s/\n/\\n/g')

    echo -n '{"text": "'
    if test -n "$event_now_or_next"; then
      echo -n " $event_now_or_next"
      test "$count_upcoming" -gt 1 && echo -n " [+$(($count_upcoming - 1))]"
    elif test "0$count_upcoming" -gt 0; then
      echo -n " $count_upcoming upcoming"
    else
      echo -n " ‹nix›"
    fi
    echo -n '", "tooltip": "'$tooltip'"}'
  '';

  widgets.tasks = pkgs.writeShellScript "task-open" ''
    ${task} -DELETED -COMPLETED export | ${jq} -Mc '{
      text: . | length | tostring | (" " + .),
      tooltip: map(
          (.priority | if . == "H" then "󰁝 " elif . == "M" then "󰁔 " elif . == "L" then "󰁅 " else "" end) +
          "<b>" + .description + "</b>" +
          (if .recur then " 󰑖" else "" end) +
          (.project | if . then " 󰀼 " + . else "" end) +
          (.tags | if . then " <small>" + (map("󰓹 " + .) | join(" ")) + "</small>" else "" end)
        ) | join("\n")
      }'
  '';

in
{
  programs.waybar = {
    settings = {
      main-bar = {
        modules-left = lib.mkForce [
          "clock"
          "custom/calendar"
          "custom/mails"
          "custom/tasks"
        ];

        "custom/mails" = {
          format = "{}";
          interval = 300;
          exec = widgets.notmuch.outPath;
          return-type = "json";
          tooltip = true;
          on-click = "\${TERMINAL_EMULATOR} -e ansicht";
        };

        "custom/calendar" = {
          format = "{}";
          interval = 300;
          exec = widgets.khal.outPath;
          on-click = "\${TERMINAL_EMULATOR} -e ikhal";
          return-type = "json";
          max-length = 32;
        };

        "custom/tasks" = {
          format = "{}";
          interval = 300;
          exec = widgets.tasks.outPath;
          on-click = "\${TERMINAL_EMULATOR} -e vim ~/wiki/index.md";
          return-type = "json";
        };
      };
    };
  };
}
