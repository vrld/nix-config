{
  pkgs,
  color-scheme,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
in {

  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    window = {
      decorations = "none";
      dynamic_padding = true;
      opacity = 0.98;
    };

    env.TERM = "xterm-256color";

    font = {
      size = 14.0;
      normal = { family = "Hack Nerd Font Mono"; style = "Regular"; };
    };

    selection.save_to_clipboard = true;

    colors = {
      draw_bold_text_with_bright_colors = false;
      indexed_colors = [
        { index = 88; color = "#${color-scheme.palette.faded_red}"; }
        { index = 124; color = "#${color-scheme.palette.neutral_red}"; }
        { index = 167; color = "#${color-scheme.palette.bright_red}"; }

        { index = 100; color = "#${color-scheme.palette.faded_green}"; }
        { index = 106; color = "#${color-scheme.palette.neutral_green}"; }
        { index = 142; color = "#${color-scheme.palette.bright_green}"; }

        { index = 136; color = "#${color-scheme.palette.faded_yellow}"; }
        { index = 172; color = "#${color-scheme.palette.neutral_yellow}"; }
        { index = 214; color = "#${color-scheme.palette.bright_yellow}"; }

        { index = 24; color = "#${color-scheme.palette.faded_blue}"; }
        { index = 67; color = "#${color-scheme.palette.neutral_blue}"; }
        { index = 109; color = "#${color-scheme.palette.bright_blue}"; }

        { index = 96; color = "#${color-scheme.palette.faded_purple}"; }
        { index = 132; color = "#${color-scheme.palette.neutral_purple}"; }
        { index = 175; color = "#${color-scheme.palette.bright_purple}"; }

        { index = 66; color = "#${color-scheme.palette.faded_aqua}"; }
        { index = 72; color = "#${color-scheme.palette.neutral_aqua}"; }
        { index = 108; color = "#${color-scheme.palette.bright_aqua}"; }

        { index = 138; color = "#${color-scheme.palette.faded_orange}"; }
        { index = 166; color = "#${color-scheme.palette.neutral_orange}"; }
        { index = 208; color = "#${color-scheme.palette.bright_orange}"; }

        { index = 228; color = "#${color-scheme.palette.light0_soft}"; }
        { index = 229; color = "#${color-scheme.palette.light0}"; }
        { index = 230; color = "#${color-scheme.palette.light0_hard}"; }
        { index = 223; color = "#${color-scheme.palette.light1}"; }
        { index = 250; color = "#${color-scheme.palette.light2}"; }
        { index = 248; color = "#${color-scheme.palette.light3}"; }
        { index = 246; color = "#${color-scheme.palette.light4}"; }

        { index = 244; color = "#${color-scheme.palette.gray}"; }

        { index = 234; color = "#${color-scheme.palette.dark0_hard}"; }
        { index = 235; color = "#${color-scheme.palette.dark0}"; }
        { index = 236; color = "#${color-scheme.palette.dark0_soft}"; }
        { index = 237; color = "#${color-scheme.palette.dark1}"; }
        { index = 239; color = "#${color-scheme.palette.dark2}"; }
        { index = 241; color = "#${color-scheme.palette.dark3}"; }
        { index = 243; color = "#${color-scheme.palette.dark4}"; }
      ];
    };

    #mouse = {
    #  hide_when_typing = true;
    #  bindings = [
    #    { mouse = "Middle"; action = "PasteSelection"; }
    #  ];
    #};

    #keyboard.bindings = [
    #  { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
    #  { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
    #  { key = "PageUp"; mods = "Control|Shift"; action = "IncreaseFontSize"; }
    #  { key = "PageDown"; mods = "Control|Shift"; action = "DecreaseFontSize"; }
    #  { key = "Paste"; action = "Paste"; }
    #  { key = "Copy"; action = "Copy"; }
    #  { key = "L"; mods = "Control"; action = "ClearLogNotice"; }
    #  { key = "L"; mods = "Control"; chars = "\f"; }
    #  { key = "Home"; mode = "AppCursor"; chars = "\u001BOH"; }
    #  { key = "Home"; mode = "~AppCursor"; chars = "\u001B[H"; }
    #  { key = "End"; mode = "AppCursor"; chars = "\u001BOF"; }
    #  { key = "End"; mode = "~AppCursor"; chars = "\u001B[F"; }
    #  { key = "PageUp"; action = "ScrollPageUp"; mode = "~Alt"; mods = "Shift"; }
    #  { key = "PageUp"; chars = "\u001B[5;2~"; mode = "Alt"; mods = "Shift"; }
    #  { key = "PageUp"; mods = "Control"; chars = "\u001B[5;5~"; }
    #  { key = "PageUp"; chars = "\u001B[5~"; }
    #  { key = "PageDown"; action = "ScrollPageDown"; mode = "~Alt"; mods = "Shift"; }
    #  { key = "PageDown"; chars = "\u001B[6;2~"; mode = "Alt"; mods = "Shift"; }
    #  { key = "PageDown"; mods = "Control"; chars = "\u001B[6;5~"; }
    #  { key = "PageDown"; chars = "\u001B[6~"; }
    #  { key = "Tab"; mods = "Shift"; chars = "\u001B[Z"; }
    #  { key = "Back"; chars = "\u007F"; }
    #  { key = "Back"; mods = "Alt"; chars = "\u001B\u007F"; }
    #  { key = "Insert"; chars = "\u001B[2~"; }
    #  { key = "Delete"; chars = "\u001B[3~"; }
    #  { key = "Left"; mods = "Shift"; chars = "\u001B[1;2D"; }
    #  { key = "Left"; mods = "Control"; chars = "\u001B[1;5D"; }
    #  { key = "Left"; mods = "Alt"; chars = "\u001B[1;3D"; }
    #  { key = "Left"; mode = "~AppCursor"; chars = "\u001B[D"; }
    #  { key = "Left"; mode = "AppCursor"; chars = "\u001BOD"; }
    #  { key = "Right"; mods = "Shift"; chars = "\u001B[1;2C"; }
    #  { key = "Right"; mods = "Control"; chars = "\u001B[1;5C"; }
    #  { key = "Right"; mods = "Alt"; chars = "\u001B[1;3C"; }
    #  { key = "Right"; mode = "~AppCursor"; chars = "\u001B[C"; }
    #  { key = "Right"; mode = "AppCursor"; chars = "\u001BOC"; }
    #  { key = "Up"; mods = "Shift"; chars = "\u001B[1;2A"; }
    #  { key = "Up"; mods = "Control"; chars = "\u001B[1;5A"; }
    #  { key = "Up"; mods = "Alt"; chars = "\u001B[1;3A"; }
    #  { key = "Up"; mode = "~AppCursor"; chars = "\u001B[A"; }
    #  { key = "Up"; mode = "AppCursor"; chars = "\u001BOA"; }
    #  { key = "Down"; mods = "Shift"; chars = "\u001B[1;2B"; }
    #  { key = "Down"; mods = "Control"; chars = "\u001B[1;5B"; }
    #  { key = "Down"; mods = "Alt"; chars = "\u001B[1;3B"; }
    #  { key = "Down"; mode = "~AppCursor"; chars = "\u001B[B"; }
    #  { key = "Down"; mode = "AppCursor"; chars = "\u001BOB"; }
    #];

    general.import = [ "~/.config/alacritty/colors-dark.toml" ];
    # general.import = [ "~/.config/alacritty/colors-light.toml" ];
  };

  xdg.configFile."alacritty/colors-dark.toml".source = tomlFormat.generate "colors.toml" {
    colors = {
      primary = {
        background = "#${color-scheme.dark.bg}";
        foreground = "#${color-scheme.dark.fg}";
        dim_foreground = "#${color-scheme.dark.fg_2}";
        bright_foreground = "#${color-scheme.dark.fg_0}";
      };

      normal = {
        black = "#${color-scheme.dark.bg}";
        red = "#${color-scheme.dark.red}";
        green = "#${color-scheme.dark.green}";
        yellow = "#${color-scheme.dark.yellow}";
        blue = "#${color-scheme.dark.blue}";
        magenta = "#${color-scheme.dark.purple}";
        cyan = "#${color-scheme.dark.aqua}";
        white = "#${color-scheme.dark.gray}";
      };

      bright = {
        black = "#${color-scheme.dark.emph-gray}";
        red = "#${color-scheme.dark.emph-red}";
        green = "#${color-scheme.dark.emph-green}";
        yellow = "#${color-scheme.dark.emph-yellow}";
        blue = "#${color-scheme.dark.emph-blue}";
        magenta = "#${color-scheme.dark.emph-purple}";
        cyan = "#${color-scheme.dark.emph-aqua}";
        white = "#${color-scheme.dark.fg}";
      };
    };
  };

  xdg.configFile."alacritty/colors-light.toml".source = tomlFormat.generate "colors-light.toml" {
    colors = {
      primary = {
        background = "#${color-scheme.light.bg}";
        foreground = "#${color-scheme.light.fg}";
        dim_foreground = "#${color-scheme.light.fg_2}";
        bright_foreground = "#${color-scheme.light.fg_0}";
      };

      normal = {
        black = "#${color-scheme.light.bg}";
        red = "#${color-scheme.light.red}";
        green = "#${color-scheme.light.green}";
        yellow = "#${color-scheme.light.yellow}";
        blue = "#${color-scheme.light.blue}";
        magenta = "#${color-scheme.light.purple}";
        cyan = "#${color-scheme.light.aqua}";
        white = "#${color-scheme.light.gray}";
      };

      bright = {
        black = "#${color-scheme.light.emph-gray}";
        red = "#${color-scheme.light.emph-red}";
        green = "#${color-scheme.light.emph-green}";
        yellow = "#${color-scheme.light.emph-yellow}";
        blue = "#${color-scheme.light.emph-blue}";
        magenta = "#${color-scheme.light.emph-purple}";
        cyan = "#${color-scheme.light.emph-aqua}";
        white = "#${color-scheme.light.fg}";
      };
    };
  };

}
