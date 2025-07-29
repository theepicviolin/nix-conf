{
  inputs,
  config,
  lib,
  pkgs,
  settings,
  ...
}:
let

in
{
  options = {
    <name>.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = with config.<name>; {
    
  };
}
