{
  config,
  lib,
  #pkgs,
  #settings,
  ...
}:
let
  silk_defaults = {
    flow_ratio = 1;
    pressure_advance = 0.024;
    inherits = "SUNLU Silk PLA+ @BBL A1M";
    version = "1.10.0.36";
  };
  filaments = {
    "BBL PLA Basic Black 0.4mm Nozzle" = {
      color = "#000000";
      flow_ratio = 1.02;
      pressure_advance = 0.024;
      inherits = "Bambu PLA Basic @BBL A1M";
      version = "1.10.0.34"; # idk what this is
    };
    "BBL PLA Basic Blue 0.4mm Nozzle" = {
      color = "#0A2989";
      flow_ratio = 1;
      pressure_advance = 0.024;
      inherits = "Bambu PLA Basic @BBL A1M";
      version = "1.10.0.34";
    };
    "BBL PLA Basic Red 0.4mm Nozzle" = {
      color = "#C12E1F";
      flow_ratio = 1.03;
      pressure_advance = 0.024;
      inherits = "Bambu PLA Basic @BBL A1M";
      version = "1.10.0.34";
    };
    "BBL PLA Matte White 0.4mm Nozzle" = {
      color = "#FFFFFF";
      flow_ratio = 1.04;
      pressure_advance = 0.024;
      inherits = "Bambu PLA Matte @BBL A1M";
      version = "1.10.0.34";
    };
    "Elegoo PLA Galaxy Purple 0.4mm Nozzle" = {
      color = "#613583";
      flow_ratio = 0.96;
      pressure_advance = 0.03;
      vendor = "Elegoo";
      inherits = "Bambu PLA Galaxy @BBL A1M";
      version = "1.10.0.36";
    };
    "Sunlu Silk PLA+ Black Blue 0.4mm Nozzle" = {
      color = "#1C71D8";
    } // silk_defaults;
    "Sunlu Silk PLA+ Black White 0.4mm Nozzle" = {
      color = "#5E5C64";
    } // silk_defaults;
    "Sunlu Silk PLA+ Blue Green 0.4mm Nozzle" = {
      color = "#40BF73";
    } // silk_defaults;
    "Sunlu Silk PLA+ Blue Green Purple 0.4mm Nozzle" = {
      color = "#57E389";
    } // silk_defaults;
    "Sunlu Silk PLA+ Pink Gold 0.4mm Nozzle" = {
      color = "#FFA348";
    } // silk_defaults;
    "Sunlu Silk PLA+ Red Blue 0.4mm Nozzle" = {
      color = "#ED333B";
    } // silk_defaults;
    "Sunlu Silk PLA+ Red Yellow Blue 0.4mm Nozzle" = {
      color = "#C061CB";
    } // silk_defaults;
    "Sunlu Silk PLA+ Red Yellow Green 0.4mm Nozzle" = {
      color = "#C061CB";
    } // silk_defaults;
  };

  processes = {
    "0.20mm AR @BBL A1M" = {
      inherits = "0.20mm Standard @BBL A1M";
      prime_tower_width = 20;
      prime_volume = 10;
      sparse_infill_pattern = "gyroid";
      version = "1.10.0.35";
    };
    "0.20mm AR Silk @BBL A1M" = {
      inherits = "0.20mm Standard @BBL A1M";
      default_acceleration = 5000;
      outer_wall_acceleration = 3000;
      outer_wall_speed = 40;
      prime_tower_width = 20;
      prime_volume = 10;
      sparse_infill_density = "10%";
      sparse_infill_pattern = "gyroid";
      version = "1.10.0.35";
    };
  };

in
{
  options = {
    orcaslicer.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = with config.orcaslicer; {
    home.activation = {
      orcaslicerCfg =
        utils.mutableDotfile ".config/OrcaSlicer" "OrcaSlicer.conf"
          "user/orcaslicer/OrcaSlicer.conf";
    };
    home.file =
      (
        with lib.attrsets;
        mapAttrs' (
          name: value:
          nameValuePair (".config/OrcaSlicer/user/default/filament/${name}.json") ({
            text = builtins.toJSON ({
              default_filament_colour = [ value.color ];
              enable_pressure_advance = [
                (if (hasAttrByPath [ "pressure_advance" ] value) then "1" else "0")
              ];
              filament_flow_ratio = [
                (builtins.toString value.flow_ratio)
              ];
              filament_retract_when_changing_layer = [ "0" ];
              filament_settings_id = [ name ];
              filament_wipe = [ "0" ];
              from = "User";
              inherits = value.inherits;
              is_custom_defined = "0";
              name = name;
              pressure_advance = [
                (builtins.toString value.pressure_advance)
              ];
              version = value.version;
            });
          })
        ) filaments
      )
      // (
        with lib.attrsets;
        mapAttrs' (
          name: value:
          nameValuePair (".config/OrcaSlicer/user/default/process/${name}.json") ({
            text = builtins.toJSON (
              {
                from = "User";
                is_custom_defined = "0";
                name = name;
                print_settings_id = name;
              }
              // mergeAttrsList (
                lib.lists.map
                  (
                    attr:
                    optionalAttrs (hasAttrByPath [ attr ] value) {
                      "${attr}" = builtins.toString value.${attr};
                    }
                  )
                  [
                    "default_acceleration"
                    "inherits"
                    "outer_wall_acceleration"
                    "outer_wall_speed"
                    "prime_tower_width"
                    "prime_volume"
                    "sparse_infill_density"
                    "sparse_infill_pattern"
                    "version"
                  ]
              )
            );
          })
        ) processes
      );
  };
}
