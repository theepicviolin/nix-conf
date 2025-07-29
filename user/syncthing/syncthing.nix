{
  #config,
  # pkgs,
  settings,
  ...
}:
let
  folders = {
    proton."${settings.homedir}/Proton" = {
      label = "Proton Drive";
      id = "vhwys-cspch";
      devices = [
        "Harmony Host"
        "Numerical Nexus"
      ];
    };
    obsidian."${settings.homedir}/Documents/Obsidian" = {
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
    phonecamera."${settings.homedir}/Pictures/Phone Camera" = {
      label = "Android Camera";
      id = "sm-s928u_s4pq-photos";
      devices = [
        "Cosmic Communicator"
        "Numerical Nexus"
      ];
    };
    media."${settings.homedir}/Videos/Media" = {
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
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    guiAddress = if settings.profile == "harmony-host" then "0.0.0.0:8384" else "127.0.0.1:8384";
    settings = {
      folders =
        (if settings.sync.proton then folders.proton else { })
        // (if settings.sync.obsidian then folders.obsidian else { })
        // (if settings.sync.phonecamera then folders.phonecamera else { })
        // (if settings.sync.media then folders.media else { });
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
    };
  };
}
