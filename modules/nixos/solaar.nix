{
  config,
  lib,
  pkgs,
  inputs,
  hostName,
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
    enable = mkOption {
      type = types.bool;
      default = anyUser {
        inherit hostName;
        inherit (pkgs) system;
        pred = (u: u.ar.solaar.enable);
      };
      description = "Whether or not to enable Solaar";
    };
  };

  config = mkIf cfg.enable {
    services.solaar = {
      enable = true;
      batteryIcons = "solaar";
    };
  };
}
