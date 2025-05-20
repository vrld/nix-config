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

      "ghostty"
      "firefox"
      "homebrew/cask/docker"
      "google-drive"
      "obsidian"

      "signal"
      "slack"
      "microsoft-teams"
      "zoom"

      "ollama"
      "lm-studio"
      "comfyui"
      "spotify"
    ];

  };

}
