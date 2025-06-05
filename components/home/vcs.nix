{ pkgs, config, ...}: {

  programs.git = {
    enable = true;

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

  xdg.configFile."jj/config.toml".source = (pkgs.formats.toml {}).generate "jj/config.toml" {
    user.name = config.programs.git.userName;
    user.email = config.programs.git.userEmail;
    ui.default-command = "log";
    ui.paginate = "never";
  };

  home.packages = [ pkgs.jujutsu ];

}
