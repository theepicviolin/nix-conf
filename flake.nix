{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
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
      pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
      settings = rec {
        hostname = "numerical-nexus";
        hostnamedisplay = "Numerical Nexus";
        username = "aditya";
        fullname = "Aditya Ramanathan";
        email = "dev@adityarama.com";
        homedir = "/home/" + username;
        dotdir = "${homedir}/.dotfiles";
        wallpaper = "${dotdir}/user/wallpaper.png";
        sync = {
          proton = true;
          obsidian = true;
          phonecamera = true;
          media = true;
        };
        backups = {
          # shuf -er -n6  {a..f} {0..9} | tr -d '\n'
          # to get a random 6 character hex prefix
          prefix = "e60643-";
          path = "/run/media/${username}/Seagate Expansion Drive/Linux/backup-${hostname}-${username}";
        };
      };
    in
    {
      nixosConfigurations.${settings.hostname} = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs settings pkgs-stable; };
        modules = [
          ./system/configuration.nix
          inputs.solaar.nixosModules.default
        ];
      };

      homeConfigurations = {
        aditya = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit settings; };
          modules = [
            ./user/home.nix
          ];
        };
      };

    };
}
