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
  cfg = config.ar.grayjay;
in
{
  options.ar.grayjay = {
    enable = mkEnableOption "Grayjay";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.grayjay ];

    home.activation = {
      grayjay = mutableDotfile ".local/share/Grayjay" ./grayjay-settings;
    };
  };
}
