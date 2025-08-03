{
  pkgs,
  lib,
  ...
}: let
  # see https://gist.github.com/nat-418/d76586da7a5d113ab90578ed56069509
  fromGitHub = rev: ref: repo: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      inherit rev ref;
      url = "https://github.com/${repo}.git";
    };
  };
in {

  home.sessionVariables.EDITOR = "nvim";

  programs.neovim = {
    enable = true;

    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      ripgrep
    ];

    plugins = with pkgs.vimPlugins; [
      vim-sensible
      plenary-nvim
      {
        plugin = gruvbox-nvim;
        type = "lua";
        config = /*lua*/ ''
          require 'gruvbox'.setup{ invert_signs = true, invert_intend_guides = true }
          vim.cmd[[colorscheme gruvbox]]
        '';
      }

      # dirvish + split buffers is so much better than nerd tree
      # TODO: can I use dirvish as a file manager? map `(xdg-)open <file>` or similar command? what about previews?
      vim-dirvish
      vim-dirvish-git
      (fromGitHub "7b8ffc05e2b1fd56571f7ac77bc36e7901c9326b" "master" "bounceme/remote-viewer")
    ];

    extraConfig = /*vim*/''
      set nomodeline           " disable magic lines to set editor prefs in source files
      set exrc                 " enable reading them from .exrc ...
      set secure               " ... but only after they are whitelisted
      set grepprg=rg\ --vimgrep\ $*

      set termguicolors
      set visualbell
      set laststatus=2
      set conceallevel=3
      set colorcolumn=85
      set number
      set winborder=rounded
      set wrap list listchars=tab:∙\ ,trail:░,extends:>,precedes:< showbreak=↪
      set title titlestring=\ %f:%l%m
      set scrolloff=8

      set completeopt=fuzzy,menu,menuone,noselect
      set ignorecase smartcase  " Mixed Case => case sensitive search
      set hlsearch              " highlight matches
      set gdefault              " assume /g in regular expressions
      set mouse=a               " mouse support in [a]ll modes: [n]ormal, [v]isual, [i]nsert and [c]ommand-line
      set tabstop=2 shiftwidth=2 expandtab
      set undofile nobackup noswapfile autowriteall
      set spelllang=de,en

      nmap <silent> <leader>w <CMD>cwindow<CR>  " maybe as autocommand on write?
      nmap <silent> <C-p> <CMD>cp<CR>
      nmap <silent> <C-n> <CMD>cn<CR>
      nmap <leader>S <CMD>%/\s\+$//<CR><CMD>noh<CR>  " remove trailing spaces

      map <leader>y "*y   " yank into primary selection
      map <leader>Y "+y   " yank into secondary selection
      map <leader>p "*p   " paste from primary selection
      map <leader>P "+P   " paste from secondary selection

      tnoremap <Esc> <C-\><C-n>
    '';

    extraLuaConfig = /*lua*/''
      vim.loader.enable()  -- cache lua modules for faster loading

      vim.api.nvim_create_autocmd('FocusLost', {
        desc = 'Write all files when nvim loses focus',
        callback = function(info)
          if info.file ~= "" then
            vim.cmd[[silent! wall]]
          end
        end,
      })

      vim.api.nvim_create_autocmd('BufReadPost', {
        desc = 'Go to last visited location when opening a buffer',
        -- I have no clue how this works but it does
        command = [[if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif]]
      })

      local quickfix_fixes = vim.api.nvim_create_augroup('QuickfixFixes', { clear = true })
      vim.api.nvim_create_autocmd('QuickFixCmdPost', {
        desc = 'Open cwindow when quickfix (:make, :grep, ...) executed',
        pattern = '[^l]*',
        command ='cwindow',
        group = quickfix_fixes,
      })

      vim.api.nvim_create_autocmd('QuickFixCmdPost', {
        desc = 'Open lwindow when quickfix (:make, :grep, ...) executed',
        pattern = 'l*',
        command ='lwindow',
        group = quickfix_fixes,
      })

      vim.api.nvim_create_autocmd('BufEnter', {
        -- https://vim.fandom.com/wiki/Automatically_quit_Vim_if_quickfix_window_is_the_last
        desc = 'Close quickfix when it is the last buffer',
        group = quickfix_fixes,
        callback = function(info)
          if vim.bo.buftype ~= 'quickfix' then
            return
          end

          -- see if there is any other open window
          local run_ok, res = pcall(vim.api.nvim_win_get_buf, 2)
          if run_ok and res == -1 then
            vim.cmd[[quit!]]
          end
        end,
      })

      vim.api.nvim_create_autocmd({'InsertLeave', 'CursorHold'}, {
        desc = 'Autosave when leaving insert mode or idling',
        pattern = '*',
        command ='silent! update',
      })

      local function set_background_from_system_theme()
        -- use uv.spawn to swallow ugly error messages with vim.system
        -- undocumented, but vim.uv.spawn returns nil, "{error name}: {status}", "{error name}"
        -- see https://github.com/luvit/luv/blob/4c9fbc6cf6f3338bb0e0426710cf885ee557b540/src/process.c#L290
        -- and https://github.com/luvit/luv/blob/4c9fbc6cf6f3338bb0e0426710cf885ee557b540/src/util.c#L42 
        local handle, errstring, errname = vim.uv.spawn('is-in-light-mode', {}, vim.schedule_wrap(function(code)
          vim.o.bg = (code == 0) and 'light' or 'dark'
        end))
        if handle == nil then
          local reason = errstring:sub(errname:len()+1) -- leaves ': {status}'
          vim.notify_once("Cannot determine system theme"..reason)
        end
      end
      set_background_from_system_theme()

      vim.api.nvim_create_autocmd({'Signal', 'FocusGained'}, {
        desc = 'Set light or dark background according to the current system theme',
        pattern = 'SIGUSR1',
        callback = set_background_from_system_theme,
      })
    '';
  };
}
