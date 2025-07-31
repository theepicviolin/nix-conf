{
  config,
  lib,
  pkgs,
  # settings,
  ...
}:
with lib;
with lib.ar;
let
  cfg = config.ar.musescore;
in
{
  options.ar.musescore = {
    enable = mkEnableOption "Enable MuseScore and Muse Sounds Manager";
  };

  config = mkIf cfg.enable {
    home.file = {
      ".config/MuseScore/MuseScore4.ini".source = ./MuseScore4.ini;
    };
    home.packages = [
      pkgs.musescore
      pkgs.muse-sounds-manager
    ];
  };
}
