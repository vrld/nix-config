let
  palette = {
   dark0_hard      = "1d2021";
   dark0           = "282828";
   dark0_soft      = "32302f";
   dark1           = "3c3836";
   dark2           = "504945";
   dark3           = "665c54";
   dark4           = "7c6f64";

   gray            = "928374";

   light0_hard     = "f9f5d7";
   light0          = "fbf1c7";
   light0_soft     = "f2e5bc";
   light1          = "ebdbb2";
   light2          = "d5c4a1";
   light3          = "bdae93";
   light4          = "a89984";

   bright_red      = "fb4934";
   bright_green    = "b8bb26";
   bright_yellow   = "fabd2f";
   bright_blue     = "83a598";
   bright_purple   = "d3869b";
   bright_aqua     = "8ec07c";
   bright_orange   = "fe8019";

   neutral_red     = "cc241d";
   neutral_green   = "98971a";
   neutral_yellow  = "d79921";
   neutral_blue    = "458588";
   neutral_purple  = "b16286";
   neutral_aqua    = "689d6a";
   neutral_orange  = "d65d0e";

   faded_red       = "9d0006";
   faded_green     = "79740e";
   faded_yellow    = "b57614";
   faded_blue      = "076678";
   faded_purple    = "8f3f71";
   faded_aqua      = "427b58";
   faded_orange    = "af3a03";
  };
in {
  inherit palette;

  dark = {
    bg = palette.dark0;
    fg = palette.light1;

    gray = palette.light4;
    red = palette.neutral_red;
    green = palette.neutral_green;
    yellow = palette.neutral_yellow;
    blue = palette.neutral_blue;
    purple = palette.neutral_purple;
    aqua = palette.neutral_aqua;
    orange = palette.neutral_orange;

    emph-gray = palette.gray;
    emph-red = palette.bright_red;
    emph-green = palette.bright_green;
    emph-yellow = palette.bright_yellow;
    emph-blue = palette.bright_blue;
    emph-purple = palette.bright_purple;
    emph-aqua = palette.bright_aqua;
    emph-orange = palette.bright_orange;

    bg0_h = palette.dark0_hard;
    bg0 = palette.dark0;
    bg0_s = palette.dark0_soft;
    bg_1 = palette.dark1;
    bg_2 = palette.dark2;
    bg_3 = palette.dark3;
    bg_4 = palette.light4;
    fg_4 = palette.light4;
    fg_3 = palette.light3;
    fg_2 = palette.light2;
    fg_1 = palette.light1;
    fg_0 = palette.light0;
  };

  light = {
    bg = palette.light0;
    fg = palette.dark1;

    gray = palette.dark4;
    red = palette.neutral_red;
    green = palette.neutral_green;
    yellow = palette.neutral_yellow;
    blue = palette.neutral_blue;
    purple = palette.neutral_purple;
    aqua = palette.neutral_aqua;
    orange = palette.neutral_orange;

    emph-gray = palette.gray;
    emph-red = palette.faded_red;
    emph-green = palette.faded_green;
    emph-yellow = palette.faded_yellow;
    emph-blue = palette.faded_blue;
    emph-purple = palette.faded_purple;
    emph-aqua = palette.faded_aqua;
    emph-orange = palette.faded_orange;

    bg0_h = palette.light0_hard;
    bg0 = palette.light0;
    bg0_s = palette.light0_soft;
    bg_1 = palette.light1;
    bg_2 = palette.light2;
    bg_3 = palette.light3;
    bg_4 = palette.light4;
    fg_4 = palette.dark4;
    fg_3 = palette.dark3;
    fg_2 = palette.dark2;
    fg_1 = palette.dark1;
    fg_0 = palette.dark0;
  };
}

