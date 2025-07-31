{
  #config,
  pkgs-stable,
  lib,
  settings,
  inputs,
  ...
}:
with lib;
with lib.ar;
{
  config = {
    home.stateVersion = "25.05"; # Don't change this unless you know what you're doing!

    ar = {
      backup = disabled;
      common = enabled;
      rclone = enabled;
      git = {
        enable = true;
        name = settings.fullname;
        email = settings.email;
      };
      shells = enabled;
      syncthing = {
        enable = true;
        proton = true;
        obsidian = true;
        phonecamera = false;
        media = true;
      };
    };
  };
}
