{
  description = "NixOS configurations for momiji and fuchsia";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    pterodactyl = {
      url = "github:PadowYT2/pterodactyl.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    freesm = {
      url = "github:freesmteam/freesmlauncher/c9222c33ba25a7f4c9fbb680e8f6448162d261e2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/v0.8.0";
    };
    nixcord = {
      url = "github:4evy/nixcord/5d9cbc77242752bd5353df2407ee9cd9966fe466";
      inputs.nixpkgs-packages.follows = "nixpkgs-unstable";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    agenix,
    nixpkgs,
    pterodactyl,
    home-manager,
    zen-browser,
    spicetify,
    freesm,
    nix-flatpak,
    nixcord,
    lanzaboote,
    disko,
    ...
  }: {
    nixosConfigurations.momiji = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        nix-flatpak.nixosModules.nix-flatpak
        lanzaboote.nixosModules.lanzaboote
        ./hosts/momiji
        {
          home-manager = {
            sharedModules = [
              zen-browser.homeModules.beta
              spicetify.homeManagerModules.spicetify
              nixcord.homeModules.nixcord
            ];
            extraSpecialArgs = {inherit agenix spicetify freesm;};
          };
        }
      ];
    };
    nixosConfigurations.fuchsia = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        agenix.nixosModules.default
        disko.nixosModules.disko
        pterodactyl.nixosModules.default
        {nixpkgs.overlays = [pterodactyl.overlays.default];}
        ./hosts/fuchsia
      ];
    };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
