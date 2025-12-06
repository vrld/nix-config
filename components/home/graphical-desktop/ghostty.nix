{
  color-scheme,
  pkgs,
  lib,
  ...
}: let
  generate-scheme = colors: with colors; ''
    foreground = #${fg}
    background = #${bg}
    cursor-color = #${fg_2}
    cursor-text = #${bg0}
    selection-background = #${fg_2}
    selection-foreground = #${bg0}
    palette = 0=#${bg}
    palette = 1=#${red}
    palette = 2=#${green}
    palette = 3=#${yellow}
    palette = 4=#${blue}
    palette = 5=#${purple}
    palette = 6=#${aqua}
    palette = 7=#${gray}
    palette = 8=#${emph-gray}
    palette = 9=#${emph-red}
    palette = 10=#${emph-green}
    palette = 11=#${emph-yellow}
    palette = 12=#${emph-blue}
    palette = 13=#${emph-purple}
    palette = 14=#${emph-aqua}
    palette = 15=#${fg}
    ${common-palette}
  '';

  common-palette = with color-scheme.palette; ''
    palette = 88=#${faded_red}
    palette = 124=#${neutral_red}
    palette = 167=#${bright_red}

    palette = 100=#${faded_green}
    palette = 106=#${neutral_green}
    palette = 142=#${bright_green}

    palette = 136=#${faded_yellow}
    palette = 172=#${neutral_yellow}
    palette = 214=#${bright_yellow}

    palette = 24=#${faded_blue}
    palette = 67=#${neutral_blue}
    palette = 109=#${bright_blue}

    palette = 96=#${faded_purple}
    palette = 132=#${neutral_purple}
    palette = 175=#${bright_purple}

    palette = 66=#${faded_aqua}
    palette = 72=#${neutral_aqua}
    palette = 108=#${bright_aqua}

    palette = 138=#${faded_orange}
    palette = 166=#${neutral_orange}
    palette = 208=#${bright_orange}

    palette = 228=#${light0_soft}
    palette = 229=#${light0}
    palette = 230=#${light0_hard}
    palette = 223=#${light1}
    palette = 250=#${light2}
    palette = 248=#${light3}
    palette = 246=#${light4}

    palette = 244=#${gray}

    palette = 234=#${dark0_hard}
    palette = 235=#${dark0}
    palette = 236=#${dark0_soft}
    palette = 237=#${dark1}
    palette = 239=#${dark2}
    palette = 241=#${dark3}
    palette = 243=#${dark4}
  '';

  keybinds.common = ''
    keybind = clear
    keybind = ctrl+shift+a=select_all
    keybind = performable:ctrl+shift+c=copy_to_clipboard
    keybind = performable:ctrl+shift+v=paste_from_clipboard
    keybind = ctrl+shift+i=inspector:toggle
    keybind = ctrl+shift+j=write_screen_file:paste
    keybind = ctrl+zero=reset_font_size
    keybind = ctrl+comma=increase_font_size:1
    keybind = ctrl+period=decrease_font_size:1
    keybind = ctrl+plus=increase_font_size:1
    keybind = ctrl+minus=decrease_font_size:1
  '';

  keybinds.system = if pkgs.stdenv.isDarwin then ''
    keybind = cmd+shift+g=goto_split:up
    keybind = cmd+shift+t=goto_split:right
    keybind = cmd+shift+r=goto_split:down
    keybind = cmd+shift+n=goto_split:left
    keybind = alt+shift+n=new_split:right
    keybind = alt+shift+d=new_split:down
    keybind = cmd+shift+f=toggle_split_zoom
    keybind = cmd+shift+h=equalize_splits

    keybind = alt+shift+g=toggle_tab_overview
    keybind = cmd+shift+n=new_tab
  '' else "";

in {

  home.sessionVariables.TERMINAL_EMULATOR = lib.mkDefault "ghostty";

  home.packages = with pkgs; if stdenv.isLinux then [ ghostty ] else [];

  xdg.configFile."ghostty/config" = lib.mkForce {
    text = ''
      theme = dark:theme-dark,light:theme-light
      font-family = Hack Nerd Font Mono
      font-size = 14
      minimum-contrast = 1.250000
      selection-invert-fg-bg = true
      mouse-hide-while-typing = true
      window-padding-balance = true
      window-padding-color = extend
      window-padding-x = 2
      window-padding-y = 2
      clipboard-paste-protection = true
      ${keybinds.common}
      ${keybinds.system}
    '';
  };

  xdg.configFile."ghostty/themes/theme-light".text = generate-scheme color-scheme.light;
  xdg.configFile."ghostty/themes/theme-dark".text = generate-scheme color-scheme.dark;

  programs.zsh.initContent = ''
    if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
      source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
    fi
  '';
}
