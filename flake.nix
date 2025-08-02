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
    inputs:
    let
      default = "unstable";
      select = pkg: if default == "unstable" then inputs.${pkg} else inputs.${pkg + "-stable"};
      blueprint = select "blueprint";
    in
    blueprint {
      inputs =
        (builtins.removeAttrs inputs [
          "nixpkgs"
          "home-manager"
        ])
        // {
          nixpkgs = select "nixpkgs";
          nixpkgs-unstable = inputs.nixpkgs;
          home-manager = select "home-manager";
        };
    };
}
