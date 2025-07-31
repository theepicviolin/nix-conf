{
  config,
  pkgs,
  lib,
  settings,
  inputs,
  ...
}:
with lib.ar;
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  boot.loader.efi.canTouchEfiVariables = lib.mkForce true; # otherwise installing bootloader fails

  ar = {
    common = enabled;
    proxmox = enabled;
  };

  networking.hostId = "d8712d14"; # needed for ZFS

  environment.systemPackages = with pkgs; [
  ];

  services.vscode-server = {
    enable = true;
    installPath = "$HOME/.vscodium-server";
  };

  networking.firewall.allowedTCPPorts = [
    8384 # syncthing
    22000 # syncthing
  ];
  networking.firewall.allowedUDPPorts = [
    22000 # syncthing
    21027 # syncthing
  ];

  system.stateVersion = "25.05"; # Don't change this unless you know what you're doing!
}
