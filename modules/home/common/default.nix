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
  cfg = config.ar.common;
in
{
  options.ar.common = {
    enable = mkEnableOption "Common";
  };

  config = mkIf cfg.enable {
    ar = {
      ssh = enabled;
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
