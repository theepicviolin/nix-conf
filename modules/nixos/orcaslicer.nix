{
  config,
  lib,
  flake,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.orcaslicer;
in
{
  options.ar.orcaslicer = {
    openPorts = mkEnableOption "open firewall ports for access to 3d printer";
  };

  config = mkIf cfg.openPorts {
    networking.firewall.allowedUDPPorts = [
      1900
      2021
    ];
  };
}
