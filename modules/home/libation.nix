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
  cfg = config.ar.libation;
in
{
  options.ar.libation = {
    enable = mkEnableOption "Enable and configure Libation";
    path = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Proton/Music/Libation";
    };
  };

  config = mkIf cfg.enable {
    home.file = {
      ".local/share/Libation/appsettings.json".text = "{\"LibationFiles\": \"${cfg.path}\"}";
    };
    home.packages = [ pkgs.libation ];
  };
}
