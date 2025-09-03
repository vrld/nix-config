{ inputs, config, ... }:
{

  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true; # installs homebrew
    # enableRosetta = true;  # enables installing x86_64 packages using Rosetta 2
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "dimentium/homebrew-autoraise" = inputs.homebrew-autoraise;
    };

    mutableTaps = false;
  };

  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    taps = builtins.attrNames config.nix-homebrew.taps; # make nix-darwin recognize nix-homebrew

    brews = [
      "bitwarden-cli"
      "k3d"
      "helm"
      "kubectl"
      "gemini-cli"
    ];

    casks = [
      "karabiner-elements"
      "hammerspoon"
      "bitwarden"
      "tunnelblick"
      "dimentium/autoraise/autoraiseapp"

      "ghostty"
      "firefox"
      "homebrew/cask/docker"
      "google-drive"
      "obsidian"
      "inkscape"

      "signal"
      "slack"
      "microsoft-teams"
      "linear-linear"

      "ollama-app"
      "lm-studio"
      "comfyui"

      "spotify"
    ];

  };
}
