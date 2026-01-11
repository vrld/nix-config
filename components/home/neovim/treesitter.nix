{ pkgs, ... }: {

  programs.neovim.extraPackages = with pkgs; [
    tree-sitter
    go
    python3
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = (nvim-treesitter.withPlugins (p: with p; [
        arduino
        awk
        bash
        c
        c3
        cmake
        cooklang
        cpp
        css
        csv
        desktop
        devicetree
        diff
        dockerfile
        git_config
        git_rebase
        gitcommit
        gitignore
        go
        gomod
        gosum
        html
        ini
        javascript
        jq
        json
        julia
        kdl
        latex
        ledger
        lua
        make
        markdown
        markdown_inline
        mermaid
        nix
        printf
        python
        regex
        rst
        rust
        sql
        toml
        typescript
        yaml
        zsh
      ]));
      type = "lua";
      config = /*lua*/''
        vim.api.nvim_create_autocmd('FileType', {
          callback = function()
            pcall(vim.treesitter.start)
          end
        })
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      '';
    }

    {
      plugin = nvim-treesitter-textobjects;
      type = "lua";
      config = /*lua*/''
        do
          require("nvim-treesitter-textobjects").setup{
            select = {
              lookahead = true,
              selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V', -- linewise
                ['@class.outer'] = '<c-v>', -- blockwise
              },
            },
            move = { set_jumps = true, },
          }

          local select = require "nvim-treesitter-textobjects.select"
          vim.keymap.set({"x", "o"}, "af", function() select.select_textobject("@function.outer", "textobjects") end)
          vim.keymap.set({"x", "o"}, "if", function() select.select_textobject("@function.inner", "textobjects") end)

          vim.keymap.set({"x", "o"}, "ac", function() select.select_textobject("@class.outer", "textobjects") end)
          vim.keymap.set({"x", "o"}, "ic", function() select.select_textobject("@class.inner", "textobjects") end)

          local swap = require "nvim-treesitter-textobjects.swap"
          vim.keymap.set("n", "tsp", function() swap.swap_next("@parameter.inner") end)
          vim.keymap.set("n", "tsP", function() swap.swap_next("@parameter.outer") end)

          vim.keymap.set("n", "tsf", function() swap.swap_next("@function.inner") end)
          vim.keymap.set("n", "tsF", function() swap.swap_next("@function.outer") end)

          local move = require "nvim-treesitter-textobjects.move"
          vim.keymap.set({"n", "x", "o"}, "tgp", function() move.goto_next_start("@paramater.outer", "textobjects") end)
          vim.keymap.set({"n", "x", "o"}, "tgP", function() move.goto_previous_start("@paramater.outer", "textobjects") end)

          vim.keymap.set({"n", "x", "o"}, "tgf", function() move.goto_next_start("@function.outer", "textobjects") end)
          vim.keymap.set({"n", "x", "o"}, "tgF", function() move.goto_previous_start("@function.outer", "textobjects") end)

          vim.keymap.set({"n", "x", "o"}, "tgc", function() move.goto_next_start("@class.outer", "textobjects") end)
          vim.keymap.set({"n", "x", "o"}, "tgC", function() move.goto_previous_start("@class.outer", "textobjects") end)
        end
      '';
    }

  ];
}
