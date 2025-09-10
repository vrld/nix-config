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
        cmake
        cpp
        css
        csv
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
        jsonc
        julia
        kdl
        latex
        ledger
        lua
        make
        markdown
        markdown_inline
        nix
        python
        rust
        sql
        toml
        typescript
        yaml
      ]));
      type = "lua";
      config = /*lua*/''
        require 'nvim-treesitter.configs'.setup{
          highlight = { enable = true, }
        }
        vim.cmd[[syntax off]];
      '';
    }

    {
      plugin = nvim-treesitter-textsubjects;
      type = "lua";
      config = /*lua*/''
        -- inititialization changed in commit 9de6c64
        ((require 'nvim-treesitter-textsubjects'.configure) or (require 'nvim-treesitter.configs'.setup)){
          enable = true,
          prev_selection = ',',
          keymaps = {
            [' '] = 'textsubjects-smart',
            ['u'] = 'textsubjects-container-outer',
            ['i'] = 'textsubjects-container-inner',
          }
        }
      '';
    }
  ];
}
