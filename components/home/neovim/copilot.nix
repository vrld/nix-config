{ pkgs, ... }:
{

  programs.neovim.extraPackages = with pkgs; [ nodejs ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = opencode-nvim;
      type = "lua";
      config = /*lua*/''
        do
          local opencode = require 'opencode'
          vim.keymap.set({'n', 'v'}, '<leader>o', opencode.ask)
        end
      '';
    }

    {
      plugin = copilot-lua;
      type = "lua";
      config = /* lua */ ''
        require('copilot').setup{
          suggestion = {
            enabled = true,
            auto_trigger = false,
            keymap = {
              accept = "<C-Return>",
              accept_word = "<C-n>",
              accept_line = "<C-l>",
              next_completion = "<C-j>",
              dismiss_completion = "<C-e>",
            },
          },
          root_dir = function()
            return vim.fs.dirname(vim.fs.find({".jj", ".git"}, { upward = true })[1])
          end,
          filetypes = {
            ["*"] = false,
            python = true,
            go = true,
            html = true,
            javascript = true,
            typescript = true,
          }
        }
        vim.api.nvim_create_user_command("Vibe", require('copilot.suggestion').toggle_auto_trigger, {})
      '';
    }

  ];

}
