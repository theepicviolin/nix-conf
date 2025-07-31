{
  config,
  pkgs,
  #pkgs-stable,
  lib,
  settings,
  inputs,
  ...
}:
with lib.ar;
{
  imports = [
    ./hardware-configuration.nix
  ];

  #nixpkgs.overlays = [ (import ../overlays/printer.nix) ];

  ar = {
    common = {
      enable = true;
      graphicalBoot = true;
      autoUpgrade = true;
      autoGc = true;
    };
    _1password = enabled;
    sunshine = enabled;
    protonvpn = enabled;
    proxmox = disabled;
    virtualisation = enabled;
    printer = enabled;
    sound = enabled;
    gnome.enable = (settings.desktop-environment == "gnome");
    plasma.enable = (settings.desktop-environment == "plasma");
  };

  # Enable networking
  networking.interfaces.${settings.ethernet-interface}.wakeOnLan.enable = true; # Enable Wake-on-LAN for the wired interface

  systemd.services.user-sleep-hook = {
    description = "Notify user session of sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${
        lib.ar.notifyUserTarget {
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
        lib.ar.notifyUserTarget {
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

  # Startup solaar on boot.
  #hardware.logitech.wireless.enable = true;
  services.solaar.enable = true;

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
