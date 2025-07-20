{
  description = "Duncan Idaho, the Ghola";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-autoraise = {
      url = "github:Dimentium/homebrew-autoraise";
      flake = false;
    };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    nix-darwin,
    chaotic,
    simple-nixos-mailserver,
    hardware,
    ...
  }@inputs: let
    inherit (self) outputs;

    nixpkgs-defaults = {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [ inputs.nur.overlays.default ];
    };

    nix-flake-registry-helper = let
      lib = nixpkgs.lib;
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in {
    # register each input flake so we can use `nix shell nixpkgs#hello` instead `nix shell git://...#hello`
      nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    };

    color-scheme = import ./colors/gruvbox.nix;
    specialArgs = { inherit inputs outputs color-scheme; };
  in {
    nixosConfigurations = {

      idaho = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/idaho
          nixpkgs-defaults
          nix-flake-registry-helper
          hardware.nixosModules.lenovo-thinkpad-x280
          hardware.nixosModules.common-gpu-amd
          hardware.nixosModules.common-pc
          chaotic.nixosModules.default
        ];
      };

      # NOTE: we use nixpkgs-stable here
      stilgar = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/stilgar
          nixpkgs-defaults
          simple-nixos-mailserver.nixosModule
        ];
      };
    };

    darwinConfigurations = let
      system = "aarch64-darwin";
    in {
      siona = nix-darwin.lib.darwinSystem {
        inherit specialArgs system;
        modules = [
          ./hosts/siona
          nixpkgs-defaults
          { nixpkgs.hostPlatform = system; }
          nix-flake-registry-helper
        ];
      };
    };


  };
}
