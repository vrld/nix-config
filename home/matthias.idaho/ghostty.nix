{
  color-scheme,
  ...
}: {

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    clearDefaultKeybinds = true;
  };

  programs.ghostty.settings = {
    theme = "dark:gruvbox-dark,light:gruvbox-light";
    font-family = "Hack Nerd Font Mono";
    font-size = 14;
    selection-invert-fg-bg = true;
    minimum-contrast = 1.25;
    mouse-hide-while-typing = true;
    window-padding-x = 2;
    window-padding-y = 2;
    window-padding-balance = true;
    window-padding-color = "extend";
    window-decoration = "none";
    clipboard-paste-protection = true;
    keybind = [
      "ctrl+shift+a=select_all"
      "performable:ctrl+c=copy_to_clipboard"
      "performable:ctrl+shift+c=copy_to_clipboard"
      "performable:ctrl+shift+v=paste_from_clipboard"
      "ctrl+shift+i=inspector:toggle"
      "ctrl+shift+j=write_screen_file:paste"
      "ctrl+zero=reset_font_size"
      "ctrl+comma=increase_font_size:1"
      "ctrl+period=decrease_font_size:1"
      "ctrl+plus=increase_font_size:1"
      "ctrl+minus=decrease_font_size:1"
    ];
  };

  programs.ghostty.themes = let

    generate-scheme = colors: with colors; {
      palette = [
        "0=#${bg}"
        "1=#${red}"
        "2=#${green}"
        "3=#${yellow}"
        "4=#${blue}"
        "5=#${purple}"
        "6=#${aqua}"
        "7=#${gray}"
        "8=#${emph-gray}"
        "9=#${emph-red}"
        "10=#${emph-green}"
        "11=#${emph-yellow}"
        "12=#${emph-blue}"
        "13=#${emph-purple}"
        "14=#${emph-aqua}"
        "15=#${fg}"
      ] ++ common-palette;
      background = "#${bg}";
      foreground = "#${fg}";
      cursor-color = "#${fg_2}";
      cursor-text = "#${bg0}";
      selection-background = "#${fg_2}";
      selection-foreground = "#${bg0}";
    };

    common-palette = with color-scheme.palette; [
        "88=#${faded_red}"
        "124=#${neutral_red}"
        "167=#${bright_red}"

        "100=#${faded_green}"
        "106=#${neutral_green}"
        "142=#${bright_green}"

        "136=#${faded_yellow}"
        "172=#${neutral_yellow}"
        "214=#${bright_yellow}"

        "24=#${faded_blue}"
        "67=#${neutral_blue}"
        "109=#${bright_blue}"

        "96=#${faded_purple}"
        "132=#${neutral_purple}"
        "175=#${bright_purple}"

        "66=#${faded_aqua}"
        "72=#${neutral_aqua}"
        "108=#${bright_aqua}"

        "138=#${faded_orange}"
        "166=#${neutral_orange}"
        "208=#${bright_orange}"

        "228=#${light0_soft}"
        "229=#${light0}"
        "230=#${light0_hard}"
        "223=#${light1}"
        "250=#${light2}"
        "248=#${light3}"
        "246=#${light4}"

        "244=#${gray}"

        "234=#${dark0_hard}"
        "235=#${dark0}"
        "236=#${dark0_soft}"
        "237=#${dark1}"
        "239=#${dark2}"
        "241=#${dark3}"
        "243=#${dark4}"
    ];

  in {
    gruvbox-dark = generate-scheme color-scheme.dark;
    gruvbox-light = generate-scheme color-scheme.light;
  };
}
