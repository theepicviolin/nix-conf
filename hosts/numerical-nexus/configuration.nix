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

  home-manager.users = lib.mkForce { };

  nixpkgs.hostPlatform = "x86_64-linux";

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
      gnome.enable = (settings.desktop-environment == "gnome");
      plasma.enable = (settings.desktop-environment == "plasma");
    };

  # Enable networking
  networking.interfaces.eno1.wakeOnLan.enable = true; # Enable Wake-on-LAN for the wired ethernet interface

  systemd.services.user-sleep-hook = {
    description = "Notify user session of sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${
        notifyUserTarget {
          inherit pkgs;
          username = "aditya";
          name = "user-sleep";
          delay = "0";
        }
      } %i";
    };
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
  };

  systemd.services.user-wake-hook = {
    description = "Notify user session of wake";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${
        notifyUserTarget {
          inherit pkgs;
          username = "aditya";
          name = "user-wake";
          delay = "1";
        }
      } %i";
    };
    wantedBy = [ "sleep.target" ];
    after = [ "sleep.target" ];
  };

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
