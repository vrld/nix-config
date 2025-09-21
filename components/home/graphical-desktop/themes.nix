{
  pkgs,
  ...
}: let
  is-in-light-mode = pkgs.writeShellScriptBin "is-in-light-mode" ''
    dconf read /org/gnome/desktop/interface/color-scheme | grep -q light
  '';
  change-colors = pkgs.writeShellScriptBin "change-colors" ''
    if [[ $# -lt 1 ]]; then
      if is-in-light-mode; then
        exec $0 dark
      else
        exec $0 light
      fi
    fi

    if [[ $1 != "light" ]] && [[ $1 != "dark" ]]; then
      echo "invalid argument '$1': must be 'light' or 'dark'"
    fi

    target=$1  # light or dark
    target_cap=$(echo "$target" | sed 's:^\(.\):\u\1:g')  # Light or Dark

    niri=$(command -v niri) && $niri msg action do-screen-transition

    # set GTK theme
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-$target'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'Qogir-$target_cap'"
    dconf write /org/gnome/desktop/interface/icon-theme "'Qogir-$target_cap'"

    # TODO: how to set qt theme? this seems to be the env var $QT_STYLE_OVERRIDE

    # neovim is configured to change background on SIGUSR1, see neovim/default.nix
    pkill -SIGUSR1 nvim
    if [[ $target == "dark" ]]; then
      pkill -SIGUSR2 foot
    else
      pkill -SIGUSR1 foot
    fi
  '';
in {

  home.packages = with pkgs; [
    numix-cursor-theme
    is-in-light-mode
    change-colors
  ];

  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  home.pointerCursor = {
    package = pkgs.quintom-cursor-theme;
    name = "Quintom_Snow";
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.qogir-theme;
      name = "Qogir-Dark";
    };
    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir-Dark";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style = {
      package = pkgs.qogir-kde;
      name = "QogirDark";  # this is an env var -- how to set this in a script?
    };
  };

}
