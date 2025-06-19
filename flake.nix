{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      # url = "github:Svenum/Solaar-Flake/main"; # Uncomment line for latest unstable version
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      settings = rec {
        hostname = "numerical-nexus";
        hostnamedisplay = "Numerical Nexus";
        username = "aditya";
        fullname = "Aditya Ramanathan";
        homedir = "/home/" + username;
        dotdir = "${homedir}/.dotfiles";
        wallpaper = "${dotdir}/wallpaper.jpg";
        sync = {
          proton = true;
          obsidian = true;
          phonecamera = true;
          media = true;
        };
      };
    in
    {
      nixosConfigurations.${settings.hostname} = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs settings; };
        modules = [
          ./configuration.nix
          inputs.solaar.nixosModules.default
        ];
      };

      homeConfigurations = {
        aditya = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit settings; };
          modules = [
            ./home.nix
          ];
        };
      };

    };
}
