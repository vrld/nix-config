{
  description = "Duncan Idaho, the Ghola";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
    home-manager,
    hardware,
    ...
  }@inputs: let
    inherit (self) outputs;
    color-scheme = import ./colors/gruvbox.nix;
  in {
    nixosConfigurations = {
      idaho = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs color-scheme;
        };
        modules = [ ./hosts/idaho ];
      };

    };
  };
}
