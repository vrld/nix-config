{
  pkgs,
  ...
}: {

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

      z-menu() {
        local d=$(zoxide query -l| sed -e "s#^''${HOME}#~#" | fzf +s --height=60% --preview="show-tree {}" --reverse | sed -s 's# #\\ #g')
        [ -n "$d" ] && LBUFFER="''${LBUFFER:-cd }$d"
        unset d
        zle reset-prompt
      }
      zle -N z-menu
      bindkey '^o' z-menu

      cd-menu() {
        local d=$(fd -t d | sed -e "s#^''${HOME}#~#" | fzf +s --height=80% --preview="show-tree {}" --reverse | sed -s 's# #\\ #g')
        [ -n "$d" ] && LBUFFER="''${LBUFFER:-cd }$d"
        unset d
        zle reset-prompt
      }
      zle -N cd-menu
      bindkey '^g' cd-menu

      fd-menu() {
        r=$(fd | fzf +s --height=60% --reverse --preview="preview-content {}" | sed -s 's# #\\ #g')
        [ -n "$r" ] && LBUFFER="''${LBUFFER:-vim }$r"
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

      # over-engineered prompt: | glider | date | jobs | return code | dir | git state | git branch | git action |
      local _bgcolor="5;0"
      _set-bgcolor() {
        _bgcolor=$1
        echo -n "\x1b[48;''${_bgcolor}m"
      }

      local _GLIDER_PHASE=1
      precmd() {
        local last_status=$?
        # decide main bar color wrt the system theme
        local _default_bg="5;237"
        is-in-light-mode && _default_bg="5;250"
        # in nix shell?
        if [[ -n "$IN_NIX_SHELL" ]]; then
          _set-bgcolor "5;4"
          echo -n "\x1b[38;5;15m \x1b[38;5;0m▕"
          _set-bgcolor ''${_default_bg}
        else
          _set-bgcolor ''${_default_bg}
          echo -n "\x1b[38;5;0m▕"
        fi

        # date
        _widget 7 $(date +%R:%S)

        # advance glider
        _GLIDER_PHASE=$(((_GLIDER_PHASE + 1) % 4))
        _widget $((_GLIDER_PHASE + 3)) $(_glider ''${_GLIDER_PHASE})

        # number of background jobs (optional)
        local num_jobs=$(jobs -p | rg '^\[' -c)
        [[ "$num_jobs" -gt 0 ]] && _widget 13 $(_supscript-numbers ''${num_jobs})

        # directory
        _widget 12  $(pwd | sed "s#^''${HOME}#~#")

        # failure code (optional)
        case ''${last_status} in
          0|130|148) # ok, crtl-c, ctrl-z
            ;;
          *)
            _set-bgcolor "5;1"
            _widget 15 ''${last_status}
            ;;
        esac

        # git info
        if _has-git; then
          _set-bgcolor ''${_default_bg}

          # state flags:       staged files?                                        unstaged changes?                           conflicts?
          local change_flags=$(git diff --cached --quiet || echo "\x1b[38;5;10m")$(git diff --quiet || echo "\x1b[38;5;11m")$(git ls-files --unmerged | grep -q . && echo "\x1b[38;5;9m")
          [[ -n "''${change_flags}" ]] && _widget 0 ''${change_flags}
          # branch
          local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
          [[ -n "''${branch}" ]] && _widget 10  ''${branch}
          # action
          local action=$(_git-action)
          [[ -n "''${action}" ]] && _widget 14 ''${action}
        fi

        # jj info: changeid commitid (bookmark |) description
        if _has-jj; then
          working_copy=$(jj st --ignore-working-copy --color always | awk -F ' : ' '/\(@\)/{print $2}')
          _widget 8 "''${working_copy%????}" # TODO: figure something more robust when this breaks
        fi

        # overwrite last separator, finish background and reset formatting
        echo "\x1b[1D \x1b[49;38;''${_bgcolor};7m\x1b[0m"
        return $last_status
      }

      PROMPT='%B%(?.%F{4}.%F{1})⏵ %b%f' # blue if last command succeeded, red else
      PROMPT2='%B%(?.%F{4}.%F{1})▵ %f%b'  # waiting for more input
      SPROMPT='%B%F{5}%R%b%F{8} ⇝ %B%F{4}%r%b%F{8} [nyae] %f'

      _widget() {
        local fgcolor=$1
        shift;
        echo -n "\x1b[38;5;0m▏\x1b[38;5;''${fgcolor}m$@\x1b[38;5;0m▕"
      }

      _glider() {
        echo -n "\x1b[1m"
        case "$1" in
          1) echo -n "⠬⠆";;
          2) echo -n "⢢⠆";;
          3) echo -n "⢄⡆";;
          *) echo -n "⠵⠂";;
        esac
        echo -n "\x1b[22m"
      }

      _supscript-numbers() {
        echo $@ | sed -e 's/0/⁰/g' \
                      -e 's/1/¹/g' \
                      -e 's/2/²/g' \
                      -e 's/3/³/g' \
                      -e 's/4/⁴/g' \
                      -e 's/5/⁵/g' \
                      -e 's/6/⁶/g' \
                      -e 's/7/⁷/g' \
                      -e 's/8/⁸/g' \
                      -e 's/9/⁹/g'
      }

      _has-git() { git rev-parse --is-inside-work-tree >/dev/null 2>&1 }
      _has-jj() { jj status --ignore-working-copy >/dev/null 2>&1 }

      _git-action() {
        if [[ -f .git/MERGE_HEAD ]]; then
          echo "merge"
        elif [[ -d .git/rebase-apply || -d .git/rebase-merge ]]; then
          echo "rebase"
        elif [[ -f .git/CHERRY_PICK_HEAD ]]; then
          echo "cherry-pick"
        elif [[ -f .git/BISECT_START ]]; then
          echo "bisect"
        fi
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
