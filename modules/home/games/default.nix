{
  config,
  lib,
  pkgs,
  flake,
  osConfig,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.games;
in
{
  options.ar.games = {
    enable = mkEnableOption "Enable Lutris, Prism Launcher, Steam auto launch";
  };

  config = mkIf cfg.enable {
    warnings = optional (!osConfig.programs.steam.enable) "Steam is not enabled in osConfig";

    programs.lutris = enabled;

    home.packages = with pkgs; [ prismlauncher ];

    home.activation = {
      moveLarianDir = replaceFile ".local/share/Steam/steamapps/common/Divinity Original Sin Enhanced Edition/runner.sh" ./runner.sh;
      prismLauncherCfg = mutableDottext ".local/share/PrismLauncher/prismlauncher.cfg" ''
        [General]
        ApplicationTheme=dark
        BackgroundCat=rory
        IconTheme=pe_colored
        InstanceDir=$HOME/Games/Minecraft
        Language=en_US
        MaxMemAlloc=16384
      '';
    };

    systemd.user.services.steam = {
      Unit = {
        Description = "Open Steam in the background at boot";
      };
      Service = {
        ExecStartPre = "/usr/bin/env sleep 1";
        ExecStart = "${pkgs.steam}/bin/steam -nochatui -nofriendsui -silent %U";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

  };
}
