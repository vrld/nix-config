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

        -- require 'mini.cursorword'.setup() -- lsp autocommands

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
        vim.keymap.set('n', '<leader>fg', '<CMD>Pick grep_live<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fb', '<CMD>Pick buffers<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fd', "<CMD>Pick diagnostic scope='current'<CR>", { silent = true })
        vim.keymap.set('n', '<leader>fq', "<CMD>Pick list scope='quickfix'<CR>", { silent = true })
        vim.keymap.set('n', '<leader>fl', "<CMD>Pick list scope='location'<CR>", { silent = true })
        vim.keymap.set('n', '<leader>fr', "<CMD>Pick lsp scope='references'<CR>", { silent = true })
        vim.ui.select = MiniPick.ui_select

        MiniPick.registry.jj = function()
          local items = {}
          local h = io.popen("jj status | sed -nE 's:^[MAD] (.*)$:\\1:p'")
          for item in h:lines() do
            items[#items + 1] = item
          end
          MiniPick.start{ source = { items = items, name = 'jj change' } }
        end
        vim.keymap.set('n', '<leader>fc', "<CMD>Pick jj<CR>", { silent = true })

        require 'mini.sessions'.setup{ autoread = true }
        vim.keymap.set('n', '<leader>fs', function() MiniSessions.select() end, { silent = true })

        require 'mini.starter'.setup()
      end
      '';
    }
  ];

}
