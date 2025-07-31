{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.ar;
let
  cfg = config.ar.rclone;
in
{
  options.ar.rclone = {
    enable = mkEnableOption "Enable rclone and set remotes";
  };

  config = mkIf cfg.enable {
    programs.rclone = {
      enable = true;
    };

    age.secrets.proton = {
      file = ../../../secrets/proton.age;
      mode = "600";
    };

    home.packages = [
      (pkgs.writeShellApplication {
        name = "update-proton-2fa";
        text = ''
          sed -i "/proton/,/\[/{ /^2fa = /s/.*/2fa = $1/ }" "$HOME/.config/rclone/rclone.conf"
          ${pkgs.rclone}/bin/rclone lsd proton:
        '';
      })
    ];

    home.activation.rcloneCfg = mutableDottext ".config/rclone" "rclone.conf" ''
      [proton]
      type = protondrive
      username = theepicviolin
      password = $(cat ${config.age.secrets.proton.path})
      2fa = 000000
    '';
  };
}
