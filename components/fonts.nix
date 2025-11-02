{ pkgs, ... }: {

  fonts.packages = with pkgs; [
    hackgen-nf-font
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.hack
    nerd-fonts.iosevka
    nerd-fonts.liberation
    nerd-fonts.dejavu-sans-mono
  ];

}
