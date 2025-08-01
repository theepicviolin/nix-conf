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
