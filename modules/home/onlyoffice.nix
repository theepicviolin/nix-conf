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
  cfg = config.ar.onlyoffice;
in
{
  options.ar.onlyoffice = {
    enable = mkEnableOption "Enable and configure ONLYOFFICE";
    path = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Proton/Documents";
    };
  };

  config = mkIf cfg.enable {
    home.activation = {
      onlyOfficeCfg = mutableDottext ".config/onlyoffice/DesktopEditors.conf" "[General]\nUITheme=theme-dark\nsavePath=${cfg.path}";
    };
    home.packages = [ pkgs.onlyoffice-desktopeditors ];
  };
}
