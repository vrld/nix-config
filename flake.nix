{
  description = "Duncan Idaho, the Ghola";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      #url = "github:nix-community/home-manager/release-24.11";
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
    system = "x86_64-linux";
    color-scheme = import ./colors/gruvbox.nix;
  in {
    nixosConfigurations = {
      idaho = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs outputs color-scheme;
        };
        modules = [ ./hosts/idaho ];
      };
    };

    homeConfigurations = {
      "matthias" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./home/matthias ];
        extraSpecialArgs = {
          inherit inputs outputs color-scheme;
          pkgs-stable = nixpkgs-stable.legacyPackages.${system};
        };
      };
    };
  };
}
