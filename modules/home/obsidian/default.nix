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
  cfg = config.ar.obsidian;
in
{
  options.ar.obsidian = {
    enable = mkEnableOption "Enable and configure Obsidian";
    vaultPath = mkOption {
      type = types.str;
      default = "Documents/Obsidian";
    };
  };

  config = mkIf cfg.enable {

    programs.obsidian = {
      enable = true;

      vaults.${cfg.vaultPath}.enable = true;

      defaultSettings = {
        app = {
          showUnsupportedFiles = true;
          promptDelete = false;
          livePreview = false;
          alwaysUpdateLinks = true;
        };
        appearance = {
          accentColor = "#8a5cf5";
        };

        communityPlugins = [
          (pkgs.callPackage ./plugins/file-diff.nix { })
          (pkgs.callPackage ./plugins/advanced-uri.nix { })
          (pkgs.callPackage ./plugins/obsidian-style-settings.nix { })
          (pkgs.callPackage ./plugins/excalidraw.nix { })
        ];

        themes = [ (pkgs.callPackage ./themes/garden-gnome.nix { }) ];
      };
    };

    home.activation = {
      excalidrawData = mutableDotfile "${cfg.vaultPath}/.obsidian/plugins/obsidian-excalidraw-plugin/data.json" ./plugins/excalidraw-data.json;
      obsidianStyleSettingsData = mutableDotfile "${cfg.vaultPath}/.obsidian/plugins/obsidian-style-settings/data.json" ./plugins/style-settings-data.json;
    };
  };
}
