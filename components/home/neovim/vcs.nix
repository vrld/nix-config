{ pkgs, ... }: {

  programs.neovim.plugins = with pkgs.vimPlugins; [

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

  ];
}
