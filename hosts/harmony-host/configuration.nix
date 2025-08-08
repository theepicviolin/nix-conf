{
  config,
  pkgs,
  lib,
  inputs,
  flake,
  hostName,
  ...
}:
with flake.lib;
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disk-config.nix
    inputs.disko.nixosModules.disko
    inputs.vscode-server.nixosModules.default
  ]
  ++ lib.attrsets.attrValues flake.nixosModules
  ++ lib.attrsets.attrValues flake.modules.common;

  home-manager.users = lib.mkForce { };

  boot.loader.efi.canTouchEfiVariables = lib.mkForce false; # otherwise installing bootloader fails

  ar = {
    common = enabled;
    proxmox = {
      enable = true;
      system = config.nixpkgs.hostPlatform.system;
    };
  };

  users.users.aditya = {
    isNormalUser = true;
    linger = true;
    description = "Aditya Ramanathan";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  networking.hostId = "d8712d14"; # needed for ZFS

  services.vscode-server = {
    enable = true;
    installPath = "$HOME/.vscodium-server";
  };

  system.stateVersion = "25.05"; # Don't change this unless you know what you're doing!
}
