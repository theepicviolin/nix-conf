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
      shells = {
        enable = true;
        dotdir = settings.dotdir;
      };
      syncthing = {
        enable = true;
        proton = {
          enable = true;
          folder = "${settings.homedir}/Proton";
        };
        obsidian = {
          enable = true;
          folder = "${settings.homedir}/Obsidian";
        };
        phonecamera = {
          enable = false;
          folder = "${settings.homedir}/Phone Camera";
        };
        media = {
          enable = true;
          folder = "${settings.homedir}/Media";
        };
      };
    };
  };
}
