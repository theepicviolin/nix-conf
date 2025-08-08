{
  config,
  lib,
  pkgs,
  hostName,
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
      username,
      delay,
    }:
    pkgs.writeShellScript "notify-${name}" ''
      set -e
      _USER="${username}"  # Change if needed
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
    enable = mkOption {
      type = types.bool;
      default = (length cfg.usernames) > 0;
      description = "Whether to enable systemd services that trigger a user target when the system sleeps or wakes";
    };
    usernames = mkOption {
      type = types.listOf types.str;
      default = matchingUsers {
        inherit hostName;
        inherit (pkgs) system;
        pred = (u: u.ar.user-sleep-wake.enable);
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services =
      let
        mkSleep = username: {
          description = "Notify user session of sleep";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${
              notifyUserTarget {
                name = "user-sleep";
                inherit username;
                delay = "0";
              }
            } %i";
          };
          wantedBy = [ "sleep.target" ];
          before = [ "sleep.target" ];
        };
        mkWake = username: {
          description = "Notify user session of wake";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${
              notifyUserTarget {
                name = "user-wake";
                inherit username;
                delay = "1";
              }
            } %i";
          };
          wantedBy = [ "sleep.target" ];
          after = [ "sleep.target" ];
        };
      in
      listToAttrs (
        concatMap (username: [
          (nameValuePair ("user-sleep-hook-${username}") (mkSleep username))
          (nameValuePair ("user-wake-hook-${username}") (mkWake username))
        ]) cfg.usernames
      );
  };
}
