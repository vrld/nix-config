{ ... }: {
  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [
      "Hack Nerd Font"
      "DejaVu Sans Mono"
    ];
  };
}
