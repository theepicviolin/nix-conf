{
  # config,
  lib,
  pkgs,
  # settings,
  ...
}:
{
  options = {
    musescore.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = {
    home.file = {
      ".config/MuseScore/MuseScore4.ini".source = ./MuseScore4.ini;
    };
    home.packages = [
      pkgs.musescore
      pkgs.muse-sounds-manager
    ];
  };
}
