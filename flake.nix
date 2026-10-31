{
  description = "NixOS configurations for momiji and fuchsia";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.8.0";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    freesm = {
      url = "github:freesmteam/freesmlauncher/c9222c33ba25a7f4c9fbb680e8f6448162d261e2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:4evy/nixcord/5d9cbc77242752bd5353df2407ee9cd9966fe466";
      inputs.nixpkgs-packages.follows = "nixpkgs-unstable";
    };
    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };

    calagopus = {
      url = "git+ssh://git@github.com/wanivy/nix-calagopus.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-unstable,
    ...
  }: let
    hostSystems = {
      momiji = "x86_64-linux";
      fuchsia = "x86_64-linux";
    };
    supportedSystems = nixpkgs.lib.unique (builtins.attrValues hostSystems);
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    unstableOverlay = final: _prev: {
      unstable = import nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    };

    commonModules = [
      inputs.disko.nixosModules.disko
      {nixpkgs.overlays = [unstableOverlay];}
    ];

    mkNixosSystem = {
      modules,
      specialArgs ? {},
      system,
    }:
      nixpkgs.lib.nixosSystem {
        inherit specialArgs system;
        modules = commonModules ++ modules;
      };
  in {
    nixosConfigurations = {
      momiji = mkNixosSystem {
        system = hostSystems.momiji;
        specialArgs = {inherit nixpkgs-unstable;};
        modules = [
          inputs.home-manager.nixosModules.home-manager
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.lanzaboote.nixosModules.lanzaboote
          ./hosts/momiji
          {
            home-manager = {
              sharedModules = [
                inputs.zen-browser.homeModules.beta
                inputs.spicetify.homeManagerModules.spicetify
                inputs.nixcord.homeModules.nixcord
              ];
              extraSpecialArgs = {
                inherit (inputs) agenix freesm spicetify;
              };
            };
          }
        ];
      };

      fuchsia = mkNixosSystem {
        system = hostSystems.fuchsia;
        modules = [
          inputs.agenix.nixosModules.default
          inputs.calagopus.nixosModules.default
          {nixpkgs.overlays = [inputs.calagopus.overlays.default];}
          ./hosts/fuchsia
        ];
      };
    };

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
