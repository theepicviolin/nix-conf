{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @ inputs: 
  let 
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    settings = rec {
      hostname = "numerical-nexus";
      username = "aditya";
      fullname = "Aditya Ramanathan";
      homedir = "/home/" + username;
      dotdir = "${homedir}/.dotfiles";
    };
  in {
    nixosConfigurations.${settings.hostname} = lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs settings; };
      modules = [
        ./configuration.nix
      ];
    };

    homeConfigurations = {
      aditya = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit settings; };
        modules = [ ./home.nix ];
      };
    };

  };
}
