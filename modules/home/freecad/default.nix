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
  cfg = config.ar.freecad;
in
{
  options.ar.freecad = {
    enable = mkEnableOption "Enable FreeCAD";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.freecad ];
    home.activation = {
      freecadUserCfg = mutableDotfile ".config/FreeCAD" "user.cfg" ./user.cfg;
    };
  };
}
