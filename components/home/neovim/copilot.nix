{ pkgs, ...}: {

  programs.neovim.extraPackages = with pkgs; [
    # copilot-language-server
    nodejs
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = copilot-lua;
      type = "lua";
      config = /*lua*/''
        require('copilot').setup{
          suggestion = {
            enabled = true,
            auto_trigger = false,
            keymap = {
              accept = "<C-y>",
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
        };

        vim.api.nvim_create_user_command("VIBE", function()
          require("copilot.suggestion").toggle_auto_trigger()
        end, {})
      '';
    }

    # TODO: figure out how to make this less annoying
    # {
    #   plugin = copilot-lsp;
    #   type = "lua";
    #   config = /*lua*/''
    #     vim.g.copilot_nes_debounce = 500
    #     vim.lsp.config.copilot_ls = {
    #       filetypes = { "python", "go", "html", "javascript", "typescript" },
    #     }
    #     vim.lsp.enable "copilot_ls"
    #     vim.keymap.set("n", "<tab>", function()
    #       local bufnr = vim.api.nvim_get_current_buf()
    #       local state = vim.b[bufnr].nes_state
    #       if state then
    #         -- Try to jump to the start of the suggestion edit.
    #         -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
    #         local nes = require("copilot-lsp.nes")
    #         if nes.walk_cursor_start_edit() then
    #           return nil
    #         end
    #         nes.apply_pending_nes()
    #         nes.walk_cursor_end_edit()
    #         return nil
    #       else
    #         -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
    #         return "<C-i>"
    #       end
    #     end, {desc = "Accept Copilot NES suggetion", expr = true})
    #
    #     vim.keymap.set("n", "<esc>", function()
    #       if not require("copilot-lsp.nes").clear() then
    #         -- fallback to other functionality
    #       end
    #     end, { desc = "Clear Copilot suggestion or fallback" })
    #   '';
    # }
  ];

}
