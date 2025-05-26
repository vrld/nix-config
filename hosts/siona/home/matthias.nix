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

  home.file.".sqliterc".text = ''
    .headers ON
    .mode box
  '';

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
      sw = "switch";
      swi = /*bash*/"!git switch $(git branch -a | sed 's:remotes/origin/::g' | awk '!s[$0]{print}{s[$0]++}' | fzf)";
      ci = "commit";
      st = "status -sb";
      br = "branch -a";
      hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
      adog = "log --all --decorate -tonline --graph";
      rbi = "rebase -i";
      unstage = "reset HEAD --";
      sl = "stash list --pretty=format:\"%C(red)%h%C(reset) - %C(bold magenta)(%gd)%C(reset) %<(70,trunc)%s %C(green)(%cr) (%C(bold blue)<%an>%C(reset)\"";
      theirs = "checkout --theirs";
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
