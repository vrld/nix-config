{ pkgs, ... }:
{

  programs.neovim.extraPackages = with pkgs; [
    gotestsum
    python313Packages.pytest
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = neotest;
      type = "lua";
      config = ''
        do
          local neotest = require("neotest")
          neotest.setup{
            adapters = {
              require("neotest-python"){
                args = { "-v", "--log-level", "DEBUG" },
                runner = "pytest",
                python = function()
                  local uv_marker = vim.fs.find(
                    {'uv.lock', '.python-version'},
                    { path = vim.fn.getcwd(), upward = true, stop = vim.loop.os_homedir() }
                  )[1]
                  if uv_marker and vim.fn.filereadable(uv_marker) == 1 then
                    return {"uv", "run", "python"}
                  end
                  return "python3"
                end,
              },
              require("neotest-golang"){}
            },
          }

          vim.keymap.set('n', '<leader>tr', function() neotest.run.run() end)
          vim.keymap.set('n', '<leader>tR', function() neotest.run.run{strategy="dap"} end)
          vim.keymap.set('n', '<leader>tl', function() neotest.run.run_last() end)
          vim.keymap.set('n', '<leader>tL', function() neotest.run.run_last{strategy="dap"} end)
          vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand("%")) end)
          vim.keymap.set('n', '<leader>tx', function() neotest.run.stop() end)

          vim.keymap.set('n', '<leader>to', function() neotest.output_panel.toogle() end)
          vim.keymap.set('n', '<leader>tO', function() neotest.output_panel.clear() end)

          vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end)
        end
      '';
    }

    neotest-python
    neotest-golang
  ];

}
