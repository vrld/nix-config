{
  pkgs,
  user,
  ...
}: let
  homeDirectory = "/Users/${user}";
in {

  imports = [
    ../../../home/common/neovim
    ../../../home/common/zsh
    ./ghostty.nix
  ];

  home = {
    sessionVariables = {
      EDITOR = "nvim";
    };
    stateVersion = "24.11";
    username = user;
  };

  home.packages = with pkgs; [
    jujutsu
    just
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Matthias Richter";
    userEmail = "matthias.richter@inovex.de";
    extraConfig = {
      color.branch = "auto";
      color.ui = "auto";
      diff.renamelimit = 0;
      push.default = "matching";
      init.defaultBranch = "main";
    };
    aliases = {
      diffc = "diff --cached";
      co = "checkout";
      ci = "commit";
      st = "status -sb";
      br = "branch -a";
      hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
    };
    ignores = [ "*.swo" "*.swp" ];
  };

  programs.password-store = {
    enable = true;
    settings.PASSWORD_STORE_DIR = "${homeDirectory}/.password-store";
    settings.PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    package = pkgs.pass.withExtensions (p: [ p.pass-genphrase p.pass-audit ]);
  };

}
