{
  config,
  lib,
  flake,
  hostName,
  pkgs,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.syncthing;
in
{
  options.ar.syncthing = {
    openPorts = mkOption {
      type = types.bool;
      default = anyUser {
        inherit hostName;
        inherit (pkgs) system;
        pred = (u: u.ar.syncthing.publicGui);
      };
      description = "Whether or not to open firewall ports for access to Syncthing web GUI";
    };
  };

  config = mkIf cfg.openPorts {
    networking.firewall.allowedTCPPorts = [
      8384
      # 22000
    ];
    # networking.firewall.allowedUDPPorts = [
    #   22000
    #   21027
    # ];
  };
}
