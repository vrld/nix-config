{ color-scheme, ... }: {

  programs.bat = {
    enable = true;
    config = {
      theme-dark = color-scheme.dark.name;
      theme-light = color-scheme.light.name;
    };
  };

  programs.zsh.shellAliases = {
    less = "bat -p";
    cat = "bat -pp";
  };

}
