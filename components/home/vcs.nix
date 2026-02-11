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
    ui = {
      default-command = "log";
      paginate = "auto";
      conflict-marker-style = "snapshot";
      diff-formatter = ":git"; # or :color-words (default), :summary, :stat, :types, :name-only
      # diff-editor = "meld-3";
    };
    merge-tools.meld-3.merge-args = [ "$left" "$base" "$right" "-o" "$output" "--auto-merge" ];
    remotes.origin = {
      auto-track-bookmarks = ''"feature/*" | "fix/*" | "feat/*" | "main"'';
    };
    aliases = {
      l = [ "log" "--no-pager" ];
      s = [ "st" "--no-pager" ];
      bl_ = [ "util" "exec" "--" "bash" "-c" ''jj b l -a --sort committer-date- -T 'name ++ " " ++ remote ++ "\n"' '' ];
      blr = [ "util" "exec" "--" "bash" "-c" ''jj bl_ | awk '$2 !~ /^(git)?$/' '' ];  # only remote branches (no local repo, no `git` remote)
      bll = [ "util" "exec" "--" "bash" "-c" ''jj bl_ | awk '$2 == ""' '' ];  # only local branches (no remotes)
      tb = [ "util" "exec" "--" "bash" "-c" /*bash*/''  # track branch
        bookmark=$(jj blr | fzf)
        [[ -z $bookmark ]] && exit 1
        jj b track $(echo $bookmark | awk '{print $1" --remote="$2}')
      ''];
      mb = [ "util" "exec" "--" "bash" "-c" /* bash */ ''  # move branch
          bookmark=$(jj bll | fzf)
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
