{
  pkgs,
  lib,
  hostName,
  flake,
  inputs,
  ...
}:
with flake.lib;
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.gigabyte-b550
  ]
  ++ lib.attrsets.attrValues flake.nixosModules
  ++ lib.attrsets.attrValues flake.modules.common;

  home-manager.users = lib.mkForce { }; # use standalone home-manager

  networking.hostName = hostName;

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
      orcaslicer.openPorts = true;
      protonvpn = enabled;
      proxmox = disabled;
      virtualisation = enabled;
      printer = enabled;
      solaar = enabled;
      sound = enabled;
      user-sleep-wake.usernames = [ "aditya" ];
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
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "aditya"; # auto login since there's drive encryption

  # Enable networking
  networking.interfaces.eno1.wakeOnLan.enable = true; # Enable Wake-on-LAN for the wired ethernet interface

  services.hardware.openrgb.enable = true;
  hardware.spacenavd.enable = true;

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    gparted
    openssl
  ];

  system.stateVersion = "25.05"; # Don't change this unless you know what you're doing!
}
