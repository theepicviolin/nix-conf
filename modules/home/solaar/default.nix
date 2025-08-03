{
  config,
  lib,
  flake,
  osConfig,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.solaar;
in
{
  options.ar.solaar = {
    enable = mkEnableOption "Set custom configuration for solaar";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = osConfig.services.solaar.enable;
        message = "osConfig must enable Solaar";
      }
    ];
    home.file = {
      ".config/solaar/config.yaml".source = ./config.yaml;
      ".config/solaar/rules.yaml".source = ./rules.yaml;
    };
  };
}
