{
  config,
  lib,
  pkgs,
  settings,
  ...
}:
let
  mkImportService = vmid: diskid: imagepath: {
    "import-disk-${toString vmid}" =
      let
        outpath = "/var/lib/vz/images/${toString vmid}/vm-${toString vmid}-disk-${diskid}.raw";
      in
      {
        description = "Import disk for VM ${toString vmid}";
        wantedBy = [ "multi-user.target" ];
        after = [
          "pvedaemon.service"
          "pve-storage.target"
        ];
        script = ''
          mkdir -p "/var/lib/vz/images/${toString vmid}"
          if [ ! -f "${outpath}" ]; then
            ${pkgs.curl}/bin/curl ${imagepath} -L -o /tmp/haos.qcow2.xz
            ${pkgs.xz}/bin/unxz /tmp/haos.qcow2.xz
            ${pkgs.qemu-utils}/bin/qemu-img convert /tmp/haos.qcow2 -O raw "${outpath}"
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
        };
      };
  };

in
{
  options = {
    proxmox.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = with config.proxmox; {
    services.proxmox-ve = {
      enable = true;
      ipAddress = "192.168.1.125";
      bridges = [ "vmbr0" ];
      vms = {
        haos = {
          vmid = 100;
          memory = 4096;
          cores = 2;
          sockets = 1;
          bios = "ovmf";
          kvm = false;
          net = [
            {
              model = "virtio";
              bridge = "vmbr0";
            }
          ];
          scsi = [ { file = "local:100/vm-100-disk-0.raw"; } ];
        };
      };
    };
    # TODO: make this defined from a list alongside scsi
    systemd.services =
      mkImportService 100 0
        "https://github.com/home-assistant/operating-system/releases/download/16.0/haos_ova-16.0.qcow2.xz";
    nixpkgs.overlays = [
      inputs.proxmox-nixos.overlays.${settings.system}
    ];
    networking.bridges.vmbr0.interfaces = [ "eno1" ];
    networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;
  };
}
