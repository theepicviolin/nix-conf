{
  config,
  lib,
  pkgs,
  flake,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.ar.hw_rgb;
in
{
  options.ar.hw_rgb = {
    enable = mkEnableOption "Enable dynamic fan lights based on hardware temperature";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = osConfig.services.hardware.openrgb.enable;
        message = "osConfig must enable openrgb for hw_rgb to function";
      }
    ];
    systemd.user.services.hw_rgb = {
      Unit = {
        Description = "Control RGB lights with OpenRGB based on the CPU and GPU status";
        After = [ "network.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart =
          "${
            pkgs.python313.withPackages (p: [
              p.openrgb-python
              p.psutil
              p.numpy
            ])
          }/bin/python "
          + builtins.toString ./hw_rgb.py;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    ar.user-sleep-wake = flake.lib.enabled;
    systemd.user.services.stop-hwrgb-sleep = {
      Unit = {
        Description = "Stop OpenRGB lights before sleep";
        PartOf = [ "user-sleep.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "systemctl --user stop hw_rgb.service";
      };
      Install.WantedBy = [ "user-sleep.target" ];
    };

    systemd.user.services.start-hwrgb-wake = {
      Unit = {
        Description = "Start OpenRGB lights after wake";
        PartOf = [ "user-wake.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "systemctl --user start hw_rgb.service";
      };
      Install.WantedBy = [ "user-wake.target" ];
    };
  };
}
