{ pkgs, color-scheme, ... }: {

  fonts.packages = with pkgs; [
    hackgen-nf-font
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.hack
    nerd-fonts.iosevka
    nerd-fonts.liberation
    nerd-fonts.dejavu-sans-mono
  ];

  console.colors = [
    color-scheme.dark.bg
    color-scheme.dark.red
    color-scheme.dark.green
    color-scheme.dark.yellow
    color-scheme.dark.blue
    color-scheme.dark.purple
    color-scheme.dark.aqua
    color-scheme.dark.gray
    color-scheme.dark.emph-gray
    color-scheme.dark.emph-red
    color-scheme.dark.emph-green
    color-scheme.dark.emph-yellow
    color-scheme.dark.emph-blue
    color-scheme.dark.emph-purple
    color-scheme.dark.emph-aqua
    color-scheme.dark.fg
  ];

}
