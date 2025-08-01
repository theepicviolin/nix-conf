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
  cfg = config.ar._1password;
in
{
  options.ar._1password = {
    enable = mkEnableOption "Enable 1Password ";
  };

  config = mkIf cfg.enable {
    programs._1password-gui.enable = true;

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          librewolf
        '';
        mode = "0755";
      };
    };
  };
}
