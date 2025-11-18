{ pkgs, config, ... }:
{
  programs.git = {
    enable = true;
    ignores = [
      "*.swo"
      "*.swp"
    ];
    settings = {
      color.branch = "auto";
      color.ui = "auto";
      diff.renamelimit = 0;
      push.default = "matching";
      init.defaultBranch = "main";
      alias = {
        diffc = "diff --cached";
        co = "checkout";
        sw = "switch";
        swi = /* bash */ "!git switch $(git branch -a | sed 's:remotes/origin/::g' | awk '!s[$0]{print}{s[$0]++}' | fzf)";
        ci = "commit";
        st = "status -sb";
        br = "branch -a";
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        rbi = "rebase -i";
        unstage = "reset HEAD --";
        sl = "stash list --pretty=format:\"%C(red)%h%C(reset) - %C(bold magenta)(%gd)%C(reset) %<(70,trunc)%s %C(green)(%cr) (%C(bold blue)<%an>%C(reset)\"";
        theirs = "checkout --theirs";
      };
    };
  };

  # jujutsu config
  xdg.configFile."jj/config.toml".source = (pkgs.formats.toml { }).generate "jj/config.toml" {
    user.name = config.programs.git.settings.user.name;
    user.email = config.programs.git.settings.user.email;
    signing = {
      behavior = "own"; # "drop" (remove signature after edit), "keep" (resign after edit), "own" (sign my commits), "force" (sign all)
      backend = "ssh";
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
    ui.default-command = "log";
    ui.paginate = "auto";
    ui.conflict-marker-style = "snapshot";
    ui.diff-formatter = ":git"; # or :color-words (default), :summary, :stat, :types, :name-only
    # ui.diff-editor = "meld-3";
    merge-tools.meld-3.merge-args = [ "$left" "$base" "$right" "-o" "$output" "--auto-merge" ];
    aliases = {
      l = [ "log" "--no-pager" ];
      s = [ "st" "--no-pager" ];
      bl = [ "util" "exec" "--" "bash" "-c" "jj b list -a --sort committer-date- | awk -F':' '/^[^ ]/{print $1}' | fzf" ];
      mb = [ "util" "exec" "--" "bash" "-c"
        /* bash */ ''
          bookmark=$(jj bl)
          [[ -z $bookmark ]] && exit 1
          jj b m "$bookmark" --to @ --allow-backwards
        ''
      ];
    };
  };

  home.packages = [
    pkgs.jujutsu
    pkgs.meld
  ];

}
