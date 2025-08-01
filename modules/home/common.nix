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

    nixpkgs.config.allowUnfree = true;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
