{ pkgs, ... }: {

  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = mini-nvim;
      type = "lua";
      config = /*lua*/''
      do
        local extra = require 'mini.extra'
        extra.setup()
        require 'mini.icons'.setup()

        require 'mini.ai'.setup{
          custom_textobjects = {
            B = extra.gen_ai_spec.buffer,
            I = extra.gen_ai_spec.indent,
            L = extra.gen_ai_spec.line,
          },
        }
        require 'mini.jump'.setup()
        require 'mini.splitjoin'.setup()
        require 'mini.surround'.setup()
        require 'mini.bracketed'.setup()

        require 'mini.snippets'.setup()  -- binds in insert mode: <C-j> expand snippet, <C-l>/<C-h> next/prev tabstop, <C-c> cancel
        -- TODO: add custom snippets, :help MiniSnippets.config

        require 'mini.completion'.setup{
          lsp_completion = {
            source_func = 'omnifunc',
            auto_setup = false,  -- NOTE: will be setup on attach event of LSP, see ./lsp.nix
          },
        }

        require 'mini.cursorword'.setup()
        require 'mini.indentscope'.setup{
          draw = {
            animation = function() return 0 end,
          },
          symbol = '┆',
          --symbol = '▎',
          --symbol = '▏',
          --symbol = '▕'
        }
        require 'mini.notify'.setup()
        vim.notify = require 'mini.notify'.make_notify()

        require 'mini.statusline'.setup()

        local hipatterns = require 'mini.hipatterns'
        hipatterns.setup{
          highlighters = {
            hex_color = hipatterns.gen_highlighter.hex_color(),
          }
        }

        require 'mini.pick'.setup()
        vim.keymap.set('n', '<leader>ff', '<CMD>Pick files<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fG', "<CMD>Pick git_files<CR>", { silent = true })
        vim.keymap.set('n', '<leader>fg', '<CMD>Pick grep_live<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fb', '<CMD>Pick buffers<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fB', '<CMD>Pick buf_lines<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fd', "<CMD>Pick diagnostic scope='current'<CR>", { silent = true })
        vim.keymap.set('n', '<leader>f:', '<CMD>Pick history<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fq', "<CMD>Pick list scope='quickfix'<CR>", { silent = true })
        vim.keymap.set('n', '<leader>fl', "<CMD>Pick list scope='location'<CR>", { silent = true })
        vim.keymap.set('n', '<leader>fr', "<CMD>Pick lsp scope='references'<CR>", { silent = true })
        vim.keymap.set('n', '<leader>ft', '<CMD>Pick treesitter<CR>', { silent = true })

        -- TODO: custom pickers (see :help MiniPick.registry)
        --       - git switch (pick branch)
        --       - lsp code actions (invoke)

        require 'mini.sessions'.setup()
        -- TODO: map MiniSessions.read()

        require 'mini.starter'.setup()
      end
      '';
    }
  ];

}
