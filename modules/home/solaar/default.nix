{
  config,
  lib,
  flake,
  # pkgs,
  # settings,
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
    home.file = {
      ".config/solaar/config.yaml".source = ./config.yaml;
      ".config/solaar/rules.yaml".source = ./rules.yaml;
    };

    # dconf.settings."org/gnome/shell/extensions/appindicator".custom-icons = [
    #   (lib.hm.gvariant.mkTuple [
    #     "indicator-solaar"
    #     (builtins.toString ./icon.png)
    #     ""
    #   ])
    # ];
  };
}
