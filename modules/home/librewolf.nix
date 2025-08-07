{
  config,
  lib,
  pkgs,
  flake,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.librewolf;
in
{
  options.ar.librewolf = {
    enable = mkEnableOption "LibreWolf browser";
  };

  config = mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      profiles.nix-default.id = 0;
    };
    home.activation = {
      librewolf-settings = (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d "$HOME/.librewolf/nix-default/.git" ]; then
            ${pkgs.git}/bin/git clone https://github.com/theepicviolin/LibreWolfCustomization "$HOME/.librewolf/nix-default"
          fi
        ''
      );
    };
  };
}
