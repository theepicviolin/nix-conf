{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    solaar = {
      # url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      url = "github:Svenum/Solaar-Flake/main"; # Uncomment line for latest unstable version
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
        ethernet-interface = "eno1"; # for wake on lan. `ip a` to see all interfaces, pick the right IP and MAC address
        # For switching DEs, switch the name then:
        # sudo nixos-rebuild boot --flake ~/.dotfiles && reboot
        # After booting into GNOME,
        # dconf reset -f /org/ && rh
        # Then log out and log back in
        desktop-environment = "gnome"; # "gnome" or "plasma"
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
          modules =
            [ ./user/home.nix ]
            ++ (lib.optional (
              settings.desktop-environment == "plasma"
            ) inputs.plasma-manager.homeManagerModules.plasma-manager);
        };
      };
    };
}
