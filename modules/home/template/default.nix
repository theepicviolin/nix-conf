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
  cfg = config.ar.TEMPLATE;
in
{
  options.ar.TEMPLATE = {
    enable = mkEnableOption "DESCRIPTION";
  };

  config = mkIf cfg.enable {
  };
}
