{
  #config,
  #lib,
  #pkgs,
  settings,
  ...
}:
{
  services.borgmatic.enable = true;
  services.borgmatic.frequency = "*-*-* 23:55:00";
  programs.borgmatic = {
    enable = true;
    backups.${settings.hostnamedisplay} = {
      location = {
        repositories = [
          {
            path = settings.backups.path;
            label = "Seagate Expansion Drive";
          }
        ];
        patterns = [
          "R ${settings.homedir}"
          #"- ${settings.homedir}/Proton"
          "- ${settings.homedir}/Games"
          "- ${settings.homedir}/.cache"
          "- ${settings.homedir}/.local/share/Steam/steamapps/common"
        ];
      };
      retention = {
        keepDaily = 14;
        keepWeekly = 4;
        keepMonthly = 12;
        keepYearly = 10;
        extraConfig = {
          skip_actions = [ "prune" ];
          archive_name_format = "${settings.backups.prefix}{hostname}-{now:%Y-%m-%dT%Hh%M}";
        };
      };
      consistency.checks = [
        {
          name = "repository";
          frequency = "2 weeks";
        }
        {
          name = "archives";
          frequency = "4 weeks";
        }
        {
          name = "data";
          frequency = "6 weeks";
        }
        {
          name = "extract";
          frequency = "6 weeks";
        }
      ];
    };
  };
}
