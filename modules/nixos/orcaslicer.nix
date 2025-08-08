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
  cfg = config.ar.orcaslicer;
in
{
  options.ar.orcaslicer = {
    openPorts = mkOption {
      type = types.bool;
      default = anyUser {
        inherit hostName;
        inherit (pkgs) system;
        pred = (u: u.ar.orcaslicer.enable);
      };
      description = "Whether or not to open firewall ports for access to 3d printer";
    };
  };

  config = mkIf cfg.openPorts {
    networking.firewall.allowedUDPPorts = [
      1900
      2021
    ];
  };
}
