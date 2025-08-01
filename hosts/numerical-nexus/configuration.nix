{
  config,
  pkgs,
  #pkgs-stable,
  lib,
  # settings,
  hostName,
  flake,
  inputs,
  ...
}:
with flake.lib;
{
  imports = [
    ./hardware-configuration.nix
  ]
  ++ lib.attrsets.attrValues flake.nixosModules
  ++ lib.attrsets.attrValues flake.modules.common;

  home-manager.users = lib.mkForce { }; # use standalone home-manager

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "numerical-nexus";

  ar =
    let
      settings = {
        desktop-environment = "gnome";
      };
    in
    {
      common = {
        enable = true;
        graphicalBoot = true;
        autoUpgrade = true;
        autoGc = true;
      };
      _1password = enabled;
      sunshine = {
        enable = true;
        displayname = "Numerical Nexus";
      };
      protonvpn = enabled;
      proxmox = disabled;
      virtualisation = enabled;
      printer = enabled;
      solaar = enabled;
      sound = enabled;
      user-sleep-wake = {
        enable = true;
        username = "aditya";
      };
      gnome.enable = (settings.desktop-environment == "gnome");
      plasma.enable = (settings.desktop-environment == "plasma");
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

  # Enable networking
  networking.interfaces.eno1.wakeOnLan.enable = true; # Enable Wake-on-LAN for the wired ethernet interface

  services.hardware.openrgb.enable = true;
  hardware.spacenavd.enable = true;

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    gparted
    openssl
  ];

  networking.firewall.allowedUDPPorts = [
    1900 # orcaslicer
    2021 # orcaslicer
  ];

  system.stateVersion = "25.05"; # Don't change this unless you know what you're doing!
}
