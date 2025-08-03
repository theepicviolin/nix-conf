{
  config,
  lib,
  pkgs,
  inputs,
  osConfig,
  flake,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.user-sleep-wake;
  osCfg = osConfig.ar.user-sleep-wake;
in
{
  options.ar.user-sleep-wake = {
    enable = mkEnableOption "user systemd targets for system sleep and wake";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = osCfg.enable;
        message = "osConfig must enable user-sleep-wake module";
      }
      {
        assertion = elem config.home.username osCfg.usernames;
        message = "osConfig must include user ${config.home.username} in user-sleep-wake";
      }
    ];
    systemd.user.targets.user-sleep.Unit.Description = "User pre-sleep target";
    systemd.user.targets.user-wake.Unit.Description = "User post-wake target";
  };
}
