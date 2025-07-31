{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.ar;
let
  cfg = config.ar.printer;
in
{
  options.ar.printer = {
    enable = mkEnableOption "Enable printing from the Brother printer";
  };

  config = mkIf cfg.enable {
    # Enable CUPS to print documents.
    services.printing = {
      enable = true;
      drivers = [
        pkgs.cups-brother-hll2340dw
      ];
    };
  };
}
