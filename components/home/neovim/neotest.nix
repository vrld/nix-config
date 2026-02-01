{ pkgs, ... }: {

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
          require("neotest").setup{
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
                    return "uv run python3"
                  end
                  return "python3"
                end,
              },
              require("neotest-golang"){}
            },
          }
          -- TODO: mappings
        end
      '';
    }

    neotest-python
    neotest-golang
  ];

}
