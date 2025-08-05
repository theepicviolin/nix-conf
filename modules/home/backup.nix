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
  cfg = config.ar.backup;
in
{
  imports = [ inputs.agenix.homeManagerModules.default ];

  options.ar.backup = {
    enable = mkEnableOption "Enable backups through borgmatic";
    name = mkOption { type = types.str; };
    path = mkOption { type = types.str; };
    label = mkOption { type = types.str; };
    prefix = mkOption { type = types.str; };
    patterns = mkOption { type = types.listOf types.str; };
    passphraseAgeFilename = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    age.secrets.${cfg.passphraseAgeFilename} = {
      file = secret cfg.passphraseAgeFilename;
      mode = "600";
    };

    services.borgmatic.enable = true;
    services.borgmatic.frequency = "*-*-* 23:55:00";
    programs.borgmatic = {
      enable = true;
      backups.${cfg.name} = {
        location = {
          repositories = [
            {
              path = cfg.path;
              label = cfg.label;
            }
          ];
          patterns = cfg.patterns;
        };
        storage = {
          encryptionPasscommand = "cat ${config.age.secrets.${cfg.passphraseAgeFilename}.path}";
        };
        retention = {
          keepDaily = 14;
          keepWeekly = 4;
          keepMonthly = 12;
          keepYearly = 10;
          extraConfig = {
            skip_actions = [ "prune" ];
            archive_name_format = "${cfg.prefix}{hostname}-{now:%Y-%m-%dT%Hh%M}";
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
  };
}
