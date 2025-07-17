{
  config,
  lib,
  pkgs,
  # settings,
  ...
}:
{
  options = {
    virtualisation.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = with config.virtualisation; {
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
