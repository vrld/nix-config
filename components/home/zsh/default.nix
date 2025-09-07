{
  pkgs,
  ...
}: {

  imports = [
    ./prompt.nix
  ];

  home.packages = with pkgs; [
    trash-cli
    zoxide
    zsh-fzf-tab
    zsh-autoenv
    fd
  ];

  programs.zsh = {
    enable = true;
    autocd = true;
    enableVteIntegration = true;

    shellAliases = {
      rm = "echo \"Use tp, fool\"; false";
      tp = "trash-put";
      tl = "trash-list";
      about = "man -k";
      fd = "fd -I";
      diff = "diff --color=auto";
    };

    enableCompletion = true;
    autosuggestion.enable = true;

    history = {
      append = true;
      ignoreAllDups = true;
    };

    initContent = /*bash*/''
      source "${pkgs.zsh-autoenv}/share/zsh-autoenv/autoenv.zsh"
      source "${pkgs.fzf}/share/fzf/completion.zsh"
      source "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"
      which jj >/dev/null && source <(jj util completion zsh)
      eval "$(zoxide init zsh)"

      setopt no_hup  # don't kill background jobs on exit
      setopt correct_all
      setopt prompt_subst

      zstyle ':completion::complete:*' use-cache 1
      zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
      zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

      autoload zkbd
      if [[ -f ~/.zkbd/$TERM ]]; then
        source ~/.zkbd/$TERM
      elif [[ -f ~/.zkbd/$TERM:0 ]]; then
        source ~/.zkbd/$TERM:0
      else
        echo "\x1b[1;38;5;15;48;5;1m No mappings for '$TERM'. Run 'zkbd'. \x1b[0m"
      fi

      [[ -n ''${key[Delete]} ]]   && bindkey "''${key[Delete]}"   vi-delete-char
      [[ -n ''${key[Home]} ]]     && bindkey "''${key[Home]}"     beginning-of-line
      [[ -n ''${key[End]} ]]      && bindkey "''${key[End]}"      end-of-line
      [[ -n ''${key[Insert]} ]]   && bindkey "''${key[Insert]}"   overwrite-mode
      [[ -n ''${key[PageUp]} ]]   && bindkey "''${key[PageUp]}"   history-beginning-search-backward
      [[ -n ''${key[PageDown]} ]] && bindkey "''${key[PageDown]}" history-beginning-search-forward

      choose-dir() {
        sed -e "s#^$HOME#~#" \
        | fzf +s --height=60% --preview="exa -T --color=always --icons=always --hyperlink -L2 {}" --reverse \
        | sed -E 's/ /\\ /g'
      }

      z-menu() {
        local d=$(zoxide query -l | choose-dir)
        [[ -n $d ]] && LBUFFER="''${LBUFFER:-cd } $d"
        unset d
        zle reset-prompt
      }
      zle -N z-menu
      bindkey '^o' z-menu

      cd-menu() {
        local d=$(fd -t d | choose-dir)
        [[ -n $d ]] && LBUFFER="''${LBUFFER:-cd } $d"
        unset d
        zle reset-prompt
      }
      zle -N cd-menu
      bindkey '^g' cd-menu

      fd-menu() {
        local r=$(fd | fzf +s --height=60% --reverse --preview="file -k {}" | sed -E 's/ /\\ /g')
        [[ -n $r ]] && LBUFFER="''${LBUFFER:-nvim } $r"
        unset r
        zle reset-prompt
      }
      zle -N fd-menu
      bindkey '^t' fd-menu

      history-search() {
        local cmd=$(cat $HISTFILE | fzf +s --height=60% --tac --reverse -q "^$LBUFFER")
        [ -n "$cmd" ] && LBUFFER="$cmd"
        unset cmd
        zle reset-prompt
      }
      zle -N history-search
      bindkey '^h' history-search

      wtf() {
        page=$(man -k $@ | fzf | sed 's/^\([[:alpha:]]*\) (\([[:digit:]]\+\)).*/\2 \1/')
        [ -n "$page" ] && man $(echo $page | awk '{gsub(/[\(\)]/, "", $2); print $2, $1}')
      }

      n() {
        local command=$1
        shift
        nix run nixpkgs#$command -- "$@"
      }

      # `nix shell nixpkgs#...` with much less typing
      s() {
        local args=()
        for arg in "$@"; do
          if [[ "$arg" == -* ]]; then
            args+=("$arg")
          else
            args+=("nixpkgs#$arg")
          fi
        done
        nix shell "''${args[@]}"
      }
    '';
  };

  # TODO: move to hosts
  home.file.".zkbd/linux".source = ./zkbd/linux;
  home.file.".zkbd/xterm-ghostty".source = ./zkbd/xterm-ghostty;

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --hidden --ignore --exclude .git --exclude .cache";
  };

  programs.fd.enable = true;

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.htop.enable = true;

  programs.jq.enable = true;

  programs.man.enable = true;

}
