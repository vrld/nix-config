{
  lib,
  config,
  pkgs,
  ...
}: {

  programs.neovim.plugins = lib.optionals config.programs.notmuch.enable [

      # neovimRequireCheck fails while loading `libnotmuch.so`; `ffi.load('notmuch')`
      # fails with: "... libnotmuch.so: cannot open shared object file: No such file or directory"
      # => disable the test for the failing module for now
      {
        plugin = pkgs.vimUtils.buildVimPlugin (let
            ref = "main";
            repo = "yousefakbar/notmuch.nvim";
          in {
            pname = "${lib.strings.sanitizeDerivationName repo}";
            version = ref;
            src = builtins.fetchGit {
              inherit ref;
              rev = "e4b0a6cbbe5e5281f7a6a8fa43c3e776d3eaec64";
              url = "https://github.com/${repo}.git";
            };
            nvimSkipModules = [ "notmuch.cnotmuch" ];  # << this disables the test
          });
        type = "lua";
        config = /*lua*/''
          require 'notmuch'.setup()
          vim.api.nvim_create_autocmd('FileType', {
            desc = 'Map keys: D = delete, R = mark read, U = mark unread',
            pattern = 'notmuch-threads',
            callback = function()
              vim.keymap.set('n', 'D', ':TagRm unread inbox<CR>:TagAdd deleted<CR><down>', {buffer = true})
              vim.keymap.set('n', 'R', ':TagRm unread<CR><down>', {buffer = true})
              vim.keymap.set('n', 'U', ':TagAdd unread<CR><down>', {buffer = true})
            end
          })
        '';
      }

    ];

    programs.neovim.extraWrapperArgs = lib.optionals config.programs.notmuch.enable [
      # TODO: investigate why LD_LIBRARY_PATH is not used in neovim-require-check-hook.sh
      "--suffix" "LD_LIBRARY_PATH" ":" "${lib.makeLibraryPath [ pkgs.notmuch ]}"
    ];
}
