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
  cfg = config.ar.solaar;
in
{
  imports = [ inputs.solaar.nixosModules.default ];
  options.ar.solaar = {
    enable = mkEnableOption "Enable Solaar";
  };

  config = mkIf cfg.enable {
    services.solaar = {
      enable = true;
      batteryIcons = "solaar";
    };
  };
}
