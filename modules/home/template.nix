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
  cfg = config.ar.TEMPLATE;
in
{
  options.ar.TEMPLATE = {
    enable = mkEnableOption "DESCRIPTION";
  };

  config = mkIf cfg.enable {
  };
}
