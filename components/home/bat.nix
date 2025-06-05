{

  programs.bat = {
    enable = true;
    config = {
      theme-dark = "gruvbox-dark";
      theme-light = "gruvbox-light";
    };
  };

  programs.zsh.shellAliases = {
    less = "bat -p";
    cat = "bat -pp";
  };

}
