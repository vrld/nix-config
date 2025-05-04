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

  imports = [
    ./treesitter.nix
    ./lsp.nix
    ./mini.nix
  ];

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

      # git
      {
        plugin = vim-fugitive;
        config = /*vim*/''
          nnoremap <silent> <leader>gs <CMD>G<CR>
          nnoremap <silent> <leader>gg <CMD>G commit<CR>
          nnoremap <silent> <leader>gp <CMD>G push<CR>
          nnoremap <silent> <leader>gp <CMD>G blame<CR>
        '';
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = /*lua*/''
          require 'gitsigns'.setup{
            --[[
            signs = {
              add          = { text = '' },
              change       = { text = '' },
              delete       = { text = '' },
              topdelete    = { text = '‾' },
              changedelete = { text = '󰜥' },
              untracked    = { text = '┆' },
            },
            --]]
            signcolumn = false,
            numhl = true,

            on_attach = function(bufnr)
              local gitsigns = require 'gitsigns'
              local opts = { buffer = bufnr }
              vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, opts)
              vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, opts)
              vim.keymap.set('v', '<leader>hs', function()
                gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
              end, opts)

              vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, opts)
              vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, opts)
              vim.keymap.set('v', '<leader>hr', function()
                gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
              end, opts)

              vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, opts)
              vim.keymap.set('n', '<leader>hi', gitsigns.preview_hunk, opts)
              vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line({ full = true }) end, opts)

              vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame, opts)
              vim.keymap.set('n', '<leader>tw', gitsigns.toggle_word_diff, opts)
              vim.keymap.set('n', '<leader>th', gitsigns.toggle_linehl, opts)

              vim.keymap.set({'o', 'x'}, 'ih', gitsigns.select_hunk, opts)
            end,
          }
        '';
      }
      {
        plugin = conflict-marker-vim;
        config = /*vim*/''
          let g:conflict_marker_enable_mappings = 0
          nnoremap <silent> ct <CMD>ConflictMarkerThemselves<CR>
          nnoremap <silent> co <CMD>ConflictMarkerOurselves<CR>
          nnoremap <silent> cb <CMD>ConflictMarkerBoth<CR>
          nnoremap <silent> cB <CMD>ConflictMarkerBoth!<CR>
          nnoremap <silent> cn <CMD>ConflictMarkerNone<CR>
        '';
      }

      # dirvish + split buffers is so much better than nerd tree
      vim-dirvish
      vim-dirvish-git
      (fromGitHub "7b8ffc05e2b1fd56571f7ac77bc36e7901c9326b" "master" "bounceme/remote-viewer")

      # random stuff
      kdl-vim
      {
        plugin = markdown-preview-nvim;
        config = /*vim*/''
          let g:mkdp_auto_close = 1
          let g:mkdp_filetypes = ['markdown']
        '';
      }
    ];

    extraConfig = /*vim*/''
      set nomodeline           " disable magic lines to set editor prefs in source files
      set exrc                 " enable reading them from .exrc ...
      set secure               " ... but only after they are whitelisted
      set grepprg=rg\ --vimgrep\ $*

      "set bg=dark
      set termguicolors
      set visualbell
      set laststatus=2
      set conceallevel=3
      set colorcolumn=85
      set number relativenumber
      set wrap list listchars=tab:∙\ ,trail:░,extends:>,precedes:< showbreak=↪
      set title titlestring=\ %f:%l%m
      set scrolloff=8

      if has('nvim-0.11')
        set completeopt=fuzzy,menu,menuone,preview,noselect
      else
        set completeopt=menu,menuone,preview,noselect
      endif
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

      vim.api.nvim_create_autocmd('TextYankPost', {
        desc = 'Highlight yanks',
        callback = (vim.hl or vim.highlight).on_yank,
        group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
      })

      vim.api.nvim_create_autocmd('BufReadPost', {
        desc = 'Go to last visited location when opening a buffer',
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

      local function set_background_from_dconf()
        local out = vim.system(
          {'dconf', 'read', '/org/gnome/desktop/interface/color-scheme'},
          {stderr = false, text = true}
        ):wait()
        vim.o.bg = (out.code == 0 and out.stdout:match('light') == 'light') and 'light' or 'dark'
      end
      set_background_from_dconf()

      vim.api.nvim_create_autocmd({'FocusGained', 'FocusLost'}, {
        desc = 'Set light or dark background according to the current system theme',
        callback = set_background_from_dconf,
      })
    '';
  };
}
