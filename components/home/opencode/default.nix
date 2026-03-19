{ pkgs, ... }:
let
  context-hub = import ../../../packages/context-hub.nix {inherit pkgs;};
in
{

  home.packages = [
    context-hub
  ];

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    mcp.linear = {
      type = "local";
      command = [
        "npx"
        "-y"
        "mcp-remote"
        "https://mcp.linear.app/mcp"
      ];
    };
  };

  home.file.".config/opencode/agent" = {
    source = ./agent;
    recursive = true;
  };

  home.file.".config/opencode/command" = {
    source = ./command;
    recursive = true;
  };

  home.file.".config/opencode/skills" = {
    source = ./skills;
    recursive = true;
  };

}
