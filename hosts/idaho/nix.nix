{ inputs, lib, ... }: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ inputs.nur.overlays.default ];
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than +3";
    };

    # register each input flake so we can use `nix shell nixpkgs#hello` instead `nix shell git://...#hello`
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
  };

}
