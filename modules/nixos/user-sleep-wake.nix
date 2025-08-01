{
  config,
  lib,
  pkgs,
  inputs,
  flake,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.user-sleep-wake;

  notifyUserTarget =
    {
      name,
      delay,
    }:
    pkgs.writeShellScript "notify-${name}" ''
      set -e
      _USER="${cfg.username}"  # Change if needed
      _UID=$(id -u "$_USER")
      export XDG_RUNTIME_DIR="/run/user/$_UID"

      if loginctl show-user "$_USER" | grep -q "State=active"; then
        sleep ${delay}
        systemctl --user -M "$_USER@" start ${name}.target
      fi
    '';
in
{
  options.ar.user-sleep-wake = {
    enable = mkEnableOption "Enable systemd services that trigger a user target when the system sleeps or wakes";
    username = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    systemd.services.user-sleep-hook = {
      description = "Notify user session of sleep";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${
          notifyUserTarget {
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
            name = "user-wake";
            delay = "1";
          }
        } %i";
      };
      wantedBy = [ "sleep.target" ];
      after = [ "sleep.target" ];
    };
  };
}
