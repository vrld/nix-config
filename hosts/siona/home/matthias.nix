{
  pkgs,
  user,
  ...
}: {

  imports = [
    ../../../components/home/bat.nix
    ../../../components/home/packages.nix
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
    go-task
    python311
    poetry
    ruff
  ];

  programs.home-manager.enable = true;

  programs.git = {
    userName = "Matthias Richter";
    userEmail = "matthias.richter@inovex.de";
  };

  programs.mods = {
    enable = true;
    settings = {
      default-model = "qwen3:14b";
      apis.ollama.models."qwen3:14b" = {
        aliases = [ "qwen3" ];
        max-input-chars = 650000;  # TODO?
      };
      apis.ollama.models."gemma3:12b" = {
        aliases = [ "gemma3" ];
        max-input-chars = 650000;  # TODO?
      };
      apis.ollama.models."codegemma:7b-code" = {
        aliases = [ "codegemma" ];
        max-input-chars = 650000;  # TODO?
      };
    };
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
