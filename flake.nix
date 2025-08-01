{
  description = "TheEpicViolin's NixOS configurations";

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
    proxmox-nixos = {
      url = "github:SaumonNet/proxmox-nixos";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blueprint-stable = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      blueprint = if profile == "numerical-nexus" then inputs.blueprint else inputs.blueprint-stable;
      # lib = if profile == "numerical-nexus" then nixpkgs.lib else inputs.nixpkgs-stable.lib;

      system = "x86_64-linux";
      pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
      pkgs-unstable = inputs.nixpkgs.legacyPackages.${system};
      profile = "numerical-nexus";
      secretsdir = ./secrets;
      settings = {
        common = rec {
          inherit profile;
          username = "aditya";
          fullname = "Aditya Ramanathan";
          email = "dev@adityarama.com";
          homedir = "/home/" + username;
          dotdir = "${homedir}/.dotfiles";
        };

        numerical-nexus = {
          hostnamedisplay = "Numerical Nexus";
          ethernet-interface = "eno1"; # for wake on lan. `ip a` to see all interfaces, pick the right IP and MAC address
          # For switching DEs, switch the name then:
          # sudo nixos-rebuild boot --flake ~/.dotfiles && reboot
          # After booting into GNOME,
          # dconf reset -f /org/ && rh
          # Then log out and log back in
          desktop-environment = "gnome"; # "gnome" or "plasma"
        }
        // settings.common;

        harmony-host = {
          hostnamedisplay = "Harmony Host";
          desktop-environment = ""; # "gnome" or "plasma"
        }
        // settings.common;
      };
    in
    blueprint {
      inputs = (builtins.removeAttrs inputs [ "nixpkgs" ]) // {
        nixpkgs = if profile == "numerical-nexus" then nixpkgs else inputs.nixpkgs-stable;
        nixpkgs-unstable = inputs.nixpkgs;
      };
      # inherit inputs;

      # nixpkgs.config = {
      #   allowUnfree = true;
      # };

      nixpkgs.overlays = with inputs; [
        nix-vscode-extensions.overlays.default
        proxmox-nixos.overlays.${system}
      ];

      #

      #

      #

      # nixosConfigurations.numerical-nexus = {
      #   inherit system;
      #   specialArgs = {
      #     inherit inputs pkgs-stable;
      #     settings = settings.numerical-nexus;
      #   };
      #   modules = [
      #     ./system/configuration-nn.nix
      #     inputs.solaar.nixosModules.default
      #     inputs.agenix.nixosModules.default
      #   ];
      # };

      # nixosConfigurations.harmony-host = {
      #   inherit system;
      #   specialArgs = {
      #     inherit inputs pkgs-unstable;
      #     settings = settings.harmony-host;
      #   };
      #   modules = [
      #     ./system/configuration-hh.nix
      #     inputs.agenix.nixosModules.default
      #     inputs.disko.nixosModules.disko
      #     inputs.proxmox-nixos.nixosModules.proxmox-ve
      #     inputs.vscode-server.nixosModules.default
      #   ];
      # };

      # # Add modules to all NixOS systems.
      # systems.modules.nixos = with inputs; [
      #   agenix.nixosModules.default
      # ];

      # systems.hosts.numerical-nexus = {
      #   modules = with inputs; [
      #     solaar.nixosModules.default
      #     nixos-hardware.nixosModules.gigabyte-b550
      #   ];
      #   specialArgs = {
      #     inherit pkgs-stable secretsdir;
      #     settings = settings.numerical-nexus;
      #   };
      # };

      # systems.hosts.harmony-host = {
      #   modules = with inputs; [
      #     disko.nixosModules.disko
      #     # proxmox-nixos.nixosModules.proxmox-ve
      #     vscode-server.nixosModules.default
      #   ];
      #   specialArgs = {
      #     inherit pkgs-unstable secretsdir;
      #     settings = settings.harmony-host;
      #   };
      # };

      # # Add modules to all homes.
      # homes.modules = with inputs; [
      #   agenix.homeManagerModules.default
      # ];

      # homes.users."aditya@numerical-nexus" = {
      #   modules = [ ];
      #   specialArgs = {
      #     settings = settings.numerical-nexus;
      #     inherit pkgs-stable;
      #   };
      # };

      # homes.users."aditya@harmony-host" = {
      #   modules = [ ];
      #   specialArgs = {
      #     settings = settings.harmony-host;
      #     inherit pkgs-unstable;
      #   };
      # };
    };
}
