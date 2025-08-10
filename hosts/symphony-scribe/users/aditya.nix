{
  config,
  lib,
  pkgs,
  flake,
  inputs,
  ...
}:
with lib;
with flake.lib;
{
  imports = lib.attrsets.attrValues flake.homeModules ++ lib.attrsets.attrValues flake.modules.common;
  config = {
    ar =
      let
        settings = {
          dotdir = config.home.homeDirectory + "/.dotfiles";
          hostName = builtins.baseNameOf ../.;
          fullname = "Aditya Ramanathan";
          email = "dev@adityarama.com";
        };
      in
      {
        backup = disabled;
        common = enabled;
        rclone = disabled;
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
          enable = false;
          publicGui = false;
          proton = {
            enable = true;
            folder = "${config.home.homeDirectory}/Proton";
          };
          obsidian = {
            enable = true;
            folder = "${config.home.homeDirectory}/Obsidian";
          };
          phonecamera = {
            enable = false;
            folder = "${config.home.homeDirectory}/Phone Camera";
          };
          media = {
            enable = true;
            folder = "${config.home.homeDirectory}/Media";
          };
        };
      };

    home.packages = with pkgs; [
      nil
      nixfmt-rfc-style
    ];
    home.stateVersion = "25.05"; # Don't change this unless you know what you're doing!
  };
}
