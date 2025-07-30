{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      lib = if profile == "numerical-nexus" then nixpkgs.lib else inputs.nixpkgs-stable.lib;
      system = "x86_64-linux";
      #pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.nix-vscode-extensions.overlays.default ];
      };
      pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
      profile = "numerical-nexus";
      home-manager =
        if profile == "numerical-nexus" then inputs.home-manager else inputs.home-manager-stable;
      settings = {
        common = rec {
          inherit system profile;
          username = "aditya";
          fullname = "Aditya Ramanathan";
          email = "dev@adityarama.com";
          homedir = "/home/" + username;
          dotdir = "${homedir}/.dotfiles";
        };

        numerical-nexus = rec {
          shortname = "nn";
          hostname = "numerical-nexus";
          hostnamedisplay = "Numerical Nexus";
          ethernet-interface = "eno1"; # for wake on lan. `ip a` to see all interfaces, pick the right IP and MAC address
          # For switching DEs, switch the name then:
          # sudo nixos-rebuild boot --flake ~/.dotfiles && reboot
          # After booting into GNOME,
          # dconf reset -f /org/ && rh
          # Then log out and log back in
          desktop-environment = "gnome"; # "gnome" or "plasma"
          wallpaper = "${settings.common.dotdir}/user/wallpaper.png";
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
            path = "/run/media/${settings.common.username}/Seagate Expansion Drive/Linux/backup-${hostname}-${settings.common.username}";
          };
        }
        // settings.common;

        harmony-host = rec {
          shortname = "hh";
          hostname = "harmony-host";
          hostnamedisplay = "Harmony Host";
          desktop-environment = ""; # "gnome" or "plasma"
          sync = {
            proton = true;
            obsidian = true;
            phonecamera = false;
            media = true;
          };
          backups = {
            # shuf -er -n6  {a..f} {0..9} | tr -d '\n'
            # to get a random 6 character hex prefix
            prefix = "d32c7b-";
            path = "/mnt/backup/backup-${hostname}-${settings.common.username}";
          };
        }
        // settings.common;
      };
    in
    {
      nixosConfigurations.numerical-nexus =
        if profile == "numerical-nexus" then
          lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs pkgs-stable;
              settings = settings.numerical-nexus;
            };
            modules = [
              ./system/configuration-nn.nix
              inputs.solaar.nixosModules.default
              inputs.agenix.nixosModules.default
            ];
          }
        else
          { };

      nixosConfigurations.harmony-host =
        if profile == "harmony-host" then
          lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs;
              settings = settings.harmony-host;
              pkgs-unstable = pkgs;
            };
            modules = [
              ./system/configuration-hh.nix
              inputs.agenix.nixosModules.default
              inputs.disko.nixosModules.disko
              inputs.proxmox-nixos.nixosModules.proxmox-ve
              inputs.vscode-server.nixosModules.default
            ];
          }
        else
          { };

      homeConfigurations = {
        aditya = home-manager.lib.homeManagerConfiguration {
          #inherit pkgs;
          pkgs = if profile == "numerical-nexus" then pkgs else pkgs-stable;
          extraSpecialArgs = {
            inherit inputs pkgs-stable;
            settings = settings.${profile};
          };
          modules = [
            ./user/home-${settings.${profile}.shortname}.nix
            inputs.agenix.homeManagerModules.default
          ]
          ++ (lib.optional (
            settings.${profile}.desktop-environment == "plasma"
          ) inputs.plasma-manager.homeManagerModules.plasma-manager);
        };
      };
    };
}
