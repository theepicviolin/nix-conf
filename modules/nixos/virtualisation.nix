{
  config,
  lib,
  pkgs,
  flake,
  # settings,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.virtualisation;
in
{
  options.ar.virtualisation = {
    enable = mkEnableOption "Enable Gnome Boxes and required virtualisation settings";
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
      # qemu.swtpm.enable = true;
    };
    programs.virt-manager.enable = true;
    # users.groups.libvirtd.members = [ settings.username ];
    # virtualisation.spiceUSBRedirection.enable = true;

    environment.systemPackages = with pkgs; [
      gnome-boxes
      #virtiofsd
      swtpm
    ];
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", GROUP="libvirt", MODE="0660"
    '';
  };
}

# https://www.reddit.com/r/NixOS/comments/177wcyi/best_way_to_run_a_vm_on_nixos/
# {config, pkgs, ... }:

# {
#   programs.dconf.enable = true;

#   users.users.gcis.extraGroups = [ "libvirtd" ];

#   environment.systemPackages = with pkgs; [
#     virt-manager
#     virt-viewer
#     spice
#     spice-gtk
#     spice-protocol
#     win-virtio
#     win-spice
#     gnome.adwaita-icon-theme
#   ];

#   virtualisation = {
#     libvirtd = {
#       enable = true;
#       qemu = {
#         swtpm.enable = true;
#         ovmf.enable = true;
#         ovmf.packages = [ pkgs.OVMFFull.fd ];
#       };
#     };
#     spiceUSBRedirection.enable = true;
#   };
#   services.spice-vdagentd.enable = true;
# }
