{ inputs, ...}: {

  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;  # installs homebrew
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
      "postman"

      "signal"
      "slack"
      "microsoft-teams"
      "zoom"
      "linear-linear"

      "ollama"
      "lm-studio"
      "comfyui"

      "spotify"
    ];

  };
}
