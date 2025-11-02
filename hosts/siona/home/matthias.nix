{
  pkgs,
  lib,
  user,
  ...
}:
{

  imports = [
    ../../../components/home/bat.nix
    ../../../components/home/packages.nix
    ../../../components/home/sqlite.nix
    ../../../components/home/vcs.nix
    ../../../components/home/zsh

    ../../../components/home/neovim
    ../../../components/home/neovim/copilot.nix
    ../../../components/home/neovim/lsp.nix
    ../../../components/home/neovim/markdown.nix
    ../../../components/home/neovim/mini.nix
    ../../../components/home/neovim/treesitter.nix
    ../../../components/home/neovim/vcs.nix

    ../../../components/home/graphical-desktop/ghostty.nix
  ];

  home = {
    sessionVariables = {
      EDITOR = "nvim";
    };
    stateVersion = "24.11";
    username = user;
  };

  home.packages = with pkgs; [
    go-task
    k9s
    python311
    poetry
    uv
    ruff
    pyright
    (pkgs.buildGoModule {
      name = "mcp-language-server";
      version = "0.1.1";
      src = pkgs.fetchFromGitHub {
        owner = "isaacphi";
        repo = "mcp-language-server";
        rev = "v0.1.1";
        hash = "sha256-T0wuPSShJqVW+CcQHQuZnh3JOwqUxAKv1OCHwZMr7KM=";
      };
      preBuild = ''rm -rf integrationtests'';
      vendorHash = "sha256-3NEG9o5AF2ZEFWkA9Gub8vn6DNptN6DwVcn/oR8ujW0=";
      meta = {
        description = "mcp-language-server gives MCP enabled clients access semantic tools like get definition, references, rename, and diagnostics.";
        homepage = "https://github.com/isaacphi/mcp-language-server";
        license = lib.licenses.bsd3;
      };

      buildInputs = [ ];
    })
  ];

  programs.home-manager.enable = true;

  programs.git.settings.user = {
    name = "Matthias Richter";
    email = "matthias.richter@inovex.de";
  };

  programs.mods = { enable = true; };

  home.file.".hammerspoon/init.lua".text = # lua
    ''
      hs.hotkey.bind({"alt"}, "Return", function()
        hs.osascript.applescript[[
          tell application "System Events"
            if (exists process "Ghostty") then
              tell process "Ghostty" to click menu item "New Window" of menu of menu bar item "File" of menu bar 1
            else
              tell application "Ghostty" to activate
            end if
          end tell
        ]]
      end)

      hs.hotkey.bind({"cmd"}, "b", function()
        hs.application.open("Firefox")
      end)

      -- hack to enable experimentation without rebuilding the thing
      pcall(dofile, '/Users/matthias/.hammerspoon/extra.lua')
    '';

}
