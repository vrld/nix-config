{
  color-scheme,
  ...
}:
let
  # TODO: this seems tightly coupled to gruvbox
  #       refactor when adding alternative color schemes:
  #       gruvbox-material, everforest, edge, sonokai/espresso, catppuccin, flexioki
  generate-scheme =
    colors:
    with colors;
    {
      cursor = "${bg0} ${fg_2}";
      foreground = fg;
      background = bg;
      selection-background = fg_3;
      selection-foreground = bg0_h;
      regular0 = bg;
      regular1 = red;
      regular2 = green;
      regular3 = yellow;
      regular4 = blue;
      regular5 = purple;
      regular6 = aqua;
      regular7 = gray;
      bright0 = emph-gray;
      bright1 = emph-red;
      bright2 = emph-green;
      bright3 = emph-yellow;
      bright4 = emph-blue;
      bright5 = emph-purple;
      bright6 = emph-aqua;
      bright7 = fg;

      alpha = .95;
      alpha-mode = "matching";
    }
    // common-palette;

  common-palette = with color-scheme.palette; {
    "88" = faded_red;
    "124" = neutral_red;
    "167" = bright_red;

    "100" = faded_green;
    "106" = neutral_green;
    "142" = bright_green;

    "136" = faded_yellow;
    "172" = neutral_yellow;
    "214" = bright_yellow;

    "24" = faded_blue;
    "67" = neutral_blue;
    "109" = bright_blue;

    "96" = faded_purple;
    "132" = neutral_purple;
    "175" = bright_purple;

    "66" = faded_aqua;
    "72" = neutral_aqua;
    "108" = bright_aqua;

    "138" = faded_orange;
    "166" = neutral_orange;
    "208" = bright_orange;

    "228" = light0_soft;
    "229" = light0;
    "230" = light0_hard;
    "223" = light1;
    "250" = light2;
    "248" = light3;
    "246" = light4;

    "244" = gray;

    "234" = dark0_hard;
    "235" = dark0;
    "236" = dark0_soft;
    "237" = dark1;
    "239" = dark2;
    "241" = dark3;
    "243" = dark4;
  };

in
{

  home.sessionVariables.TERMINAL_EMULATOR = "foot";

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font Mono:size=14";
        dpi-aware = "no";
        box-drawings-uses-font-glyphs = "yes";
        selection-target = "both";
      };
      colors = generate-scheme color-scheme.dark;
      colors2 = generate-scheme color-scheme.light;
      key-bindings = {
        font-increase = "Control+comma Control+plus";
        font-decrease = "Control+period Control+minus";
      };
    };
  };

}
