{
  description = "Duncan Idaho, the Ghola";

  inputs = {
    hardware.url = "github:nixos/nixos-hardware";

    # unstable on laptops
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # stable for vserver
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    sops-nix-stable = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # homebrew bridge
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

    # flatpaks
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    # übersicht mail system
    ansicht = {
      url = "github:vrld/ansicht";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    einsicht = {
      url = "github:vrld/einsicht";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    absicht = {
      url = "github:vrld/absicht";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, ... }@inputs: let
    inherit (self) outputs;

    nixpkgs-defaults = {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [ inputs.nur.overlays.default ];
    };

    nix-flake-registry-helper = let
      lib = inputs.nixpkgs.lib;
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in {
    # register each input flake so we can use `nix shell nixpkgs#hello` instead `nix shell git://...#hello`
      nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    };

    color-scheme = import ./colors/gruvbox.nix;
    specialArgs = { inherit inputs outputs color-scheme; };
  in {
    nixosConfigurations = {

      idaho = inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/idaho
          nixpkgs-defaults
          nix-flake-registry-helper
          inputs.hardware.nixosModules.lenovo-thinkpad-x280
          inputs.hardware.nixosModules.common-gpu-amd
          inputs.hardware.nixosModules.common-pc
          inputs.chaotic.nixosModules.default
        ];
      };

      # NOTE: we use nixpkgs-stable here
      stilgar = inputs.nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/stilgar
          nixpkgs-defaults
          inputs.simple-nixos-mailserver.nixosModule
        ];
      };
    };

    darwinConfigurations = let
      system = "aarch64-darwin";
    in {
      siona = inputs.nix-darwin.lib.darwinSystem {
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
