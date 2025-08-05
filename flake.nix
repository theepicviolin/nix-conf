{
  description = "TheEpicViolin's NixOS configurations";

  inputs = {
    ######################################################
    ##### SWITCH SYSTEM DEFAULT WITH THESE TWO LINES #####
    ######################################################
    nixpkgs.url = "nixpkgs/nixos-unstable"; # "nixpkgs/nixos-25.05";
    # nixpkgs.url = "nixpkgs/5a0711127cd8b916c3d3128f473388c8c79df0da"; # orca slicer works on this version
    home-manager.url = "github:nix-community/home-manager"; # "github:nix-community/home-manager/release-25.05"

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    blueprint = {
      url = "github:theepicviolin/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}
