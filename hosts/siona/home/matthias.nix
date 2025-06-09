{
  pkgs,
  user,
  ...
}: {

  imports = [
    ../../../components/home/bat.nix
    ../../../components/home/sqlite.nix
    ../../../components/home/vcs.nix
    ../../../components/home/zsh

    ../../../components/home/neovim
    ../../../components/home/neovim/llm.nix
    ../../../components/home/neovim/lsp.nix
    ../../../components/home/neovim/markdown.nix
    ../../../components/home/neovim/mini.nix
    ../../../components/home/neovim/treesitter.nix
    ../../../components/home/neovim/vcs.nix

    ../../../components/home/ghostty.nix
  ];

  home = {
    sessionVariables = {
      EDITOR = "nvim";
    };
    stateVersion = "24.11";
    username = user;
  };

  home.packages = with pkgs; [
    just
    (import ../../../packages/print256colors.nix {inherit pkgs;})
  ];

  programs.home-manager.enable = true;

  programs.git = {
    userName = "Matthias Richter";
    userEmail = "matthias.richter@inovex.de";
  };

  home.file.".hammerspoon/init.lua".text = /*lua*/''
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
