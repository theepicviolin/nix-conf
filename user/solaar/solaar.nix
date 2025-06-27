{
  # config,
  lib,
  # pkgs,
  # settings,
  ...
}:
{
  options = {
    solaar.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = {
    home.file = {
      ".config/solaar/config.yaml".source = ./config.yaml;
      ".config/solaar/rules.yaml".source = ./rules.yaml;
    };
  };
}
