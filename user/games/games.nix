{
  config,
  lib,
  pkgs,
  settings,
  ...
}:
{
  options = {
    games.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = with config.games; {

    programs.lutris = {
      enable = true;
    };

    home.packages = with pkgs; [ prismlauncher ];

    home.activation = {
      moveLarianDir =
        utils.replaceFile ".local/share/Steam/steamapps/common/Divinity Original Sin Enhanced Edition"
          "runner.sh"
          "user/games/runner.sh";
      prismLauncherCfg = utils.mutableDottext ".local/share/PrismLauncher" "prismlauncher.cfg" ''
        [General]
        ApplicationTheme=dark
        BackgroundCat=rory
        IconTheme=pe_colored
        InstanceDir=${settings.homedir}/Games/Minecraft
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
