{
  config,
  lib,
  host,
  # pkgs,
  # settings,
  ...
}:
with lib;
with lib.ar;
let
  cfg = config.ar.syncthing;
  folders = {
    proton = {
      label = "Proton Drive";
      id = "vhwys-cspch";
      devices = [
        "Harmony Host"
        "Numerical Nexus"
      ];
    };
    obsidian = {
      label = "Obsidian";
      id = "txpxx-3pgud";
      devices = [
        "Cosmic Communicator"
        "Symphony Scribe"
        "Gaming Gateway"
        "Harmony Host"
        "Numerical Nexus"
      ];
    };
    phonecamera = {
      label = "Android Camera";
      id = "sm-s928u_s4pq-photos";
      devices = [
        "Cosmic Communicator"
        "Numerical Nexus"
      ];
    };
    media = {
      label = "Media";
      id = "txvrc-k9e3j";
      devices = [
        "Harmony Host"
        "Numerical Nexus"
      ];
    };
  };

in
{
  options.ar.syncthing =
    let
      folderOpts =
        name:
        types.submodule {
          options = {
            enable = mkEnableOption "Sync ${name}";
            folder = mkOption {
              type = types.str;
              description = "Folder to keep ${name} synced at";
            };
          };
        };
    in
    {
      enable = mkEnableOption "Enable syncthing";
      proton = mkOption { type = folderOpts "Proton Drive"; };
      obsidian = mkOption { type = folderOpts "Obsidian vault"; };
      phonecamera = mkOption { type = folderOpts "phone camera"; };
      media = mkOption { type = folderOpts "media"; };
    };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      overrideDevices = true;
      overrideFolders = true;
      guiAddress = if host == "harmony-host" then "0.0.0.0:8384" else "127.0.0.1:8384";
      settings = {
        folders = {
          "${cfg.proton.folder}" = mkIf cfg.proton.enable folders.proton;
          "${cfg.obsidian.folder}" = mkIf cfg.obsidian.enable folders.obsidian;
          "${cfg.phonecamera.folder}" = mkIf cfg.phonecamera.enable folders.phonecamera;
          "${cfg.media.folder}" = mkIf cfg.media.enable folders.media;
        };

        devices = {
          "Harmony Host" = {
            id = "DRUIO77-3KOGL7S-IPZWW3A-WB3PTFH-EIFQPBI-OGCQZ6G-UI46K3G-WD552QP";
          };
          "Cosmic Communicator" = {
            id = "4DEABWB-EIXG52R-SB2D7FX-ADQM3FA-VV5T4V6-HD55MZ5-NB6EJH4-3T4X2QZ";
          };
          "Symphony Scribe" = {
            id = "2ZOEOS6-ZYDGC6T-W63AEYR-OJWRY44-PW6PNN6-AS7YZZO-J4WOIQZ-D7GZOAE";
          };
          "Gaming Gateway" = {
            id = "AT2S45P-GGZEREE-M6XG2Z2-5TPTGF5-SPZLNHD-IIQWUEH-6KVJLNU-DL7RLQH";
          };
          "Numerical Nexus" = {
            id = "HOGUXNL-5T266FP-H3AX6JB-ZSQV4LD-IND5BGQ-X42UL45-SVDQN7R-REBUSQQ";
          };
        };
        options.urAccepted = -1;
        gui = {
          tls = "true";
          theme = "dark";
          user = "aditya";
        };
      };
      extraOptions = [ "--no-default-folder" ]; # Don't create default ~/Sync folder
      passwordFile = builtins.toPath config.age.secrets.syncthing.path;
    };

    age.secretsDir = "/run/user/1000/agenix";
    age.secrets.syncthing = {
      file = ../../../secrets/syncthing.age;
      mode = "600";
    };
  };
}
