{
  inputs,
  pkgs,
  outputs,
  color-scheme,
  ...
}: let
  pkgs-stable = import inputs.nixpkgs-stable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
  user = "matthias";
in {

  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./aerospace.nix
  ];

  system.primaryUser = user;
  users.users.${user} = {
    shell = pkgs.zsh;
    home = /Users/${user};
    packages = [
      (pkgs.writeShellScriptBin "is-in-light-mode" "! defaults read -g AppleInterfaceStyle >/dev/null 2>&1")
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = import ./${user}.nix;
    extraSpecialArgs = { inherit inputs outputs color-scheme pkgs-stable user; };
  };

  nix-homebrew = {
    inherit user;
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
