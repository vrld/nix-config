{ pkgs, ... }: {

  programs.neovim.extraPackages = with pkgs; [
    python313Packages.debugpy
    delve
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = nvim-dap;
      type = "lua";
      config = ''
        vim.fn.sign_define('DapBreakpoint', {text="", texthl="", linehl="", numhl=""})
        vim.fn.sign_define('DapBreakpointCondition', {text="", texthl="", linehl="", numhl=""})
        vim.fn.sign_define('DapBreapointRejected', {text="", texthl="", linehl="", numhl=""})
        vim.fn.sign_define('DapLogPoint', {text="", texthl="", linehl="", numhl=""})
        vim.fn.sign_define('DapStopped', {text="➤", texthl="", linehl="", numhl=""})
        vim.api.nvim_create_autocmd('FileType', {
          pattern = "dap-repl",
          callback = function() require("dap.ext.autocompl").attach() end,
        })
        -- TODO: key mappings?
      '';
    }

    {
      plugin = nvim-dap-virtual-text;
      type = "lua";
      config = ''
        require("nvim-dap-virtual-text").setup {
          all_references = true,  -- show virtual text on all all references of the variable (not only definitions)
          clear_on_continue = true,  -- clear virtual text on "continue" (might cause flickering when stepping)
        }
      '';
    }

    {
      plugin = nvim-dap-view;
      type = "lua";
      config = ''
        require("dap-view").setup{
          winbar = {
            controls = {
              enabled = true,
            },
          },
        }
      '';
    }


    {
      plugin = nvim-dap-python;
      type = "lua";
      config = ''
        vim.api.nvim_create_autocmd('FileType', {
          pattern = "python",
          callback = function()
            local uv_marker = vim.fs.find(
              {'uv.lock', '.python-version'},
              { path = vim.fn.getcwd(), upward = true, stop = vim.loop.os_homedir() }
            )[1]
            if uv_marker and vim.fn.filereadable(uv_marker) == 1 then
              require('dap-python').setup("uv")
            else
              require('dap-python').setup()
            end
          end,
        })
      '';
    }

    {
      plugin = nvim-dap-go;
      type = "lua";
      config = ''
        vim.api.nvim_create_autocmd('FileType', {
          pattern = "go",
          callback = function()
            require('dap-go').setup()
          end,
        })
      '';
    }
  ];

}
