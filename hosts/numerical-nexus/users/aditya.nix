{
  config,
  pkgs,
  pkgs-stable,
  lib,
  # settings,
  # host,
  # hostName,
  flake,
  inputs,
  ...
}:
with lib;
with flake.lib;
{
  imports = [
  ]
  ++ lib.attrsets.attrValues flake.homeModules
  ++ lib.attrsets.attrValues flake.modules.common;

  config = {
    # nixpkgs.overlays = [ (import ../overlays/frescobaldi.nix) ];
    # home.username = settings.username;
    # home.homeDirectory = settings.homedir;

    home.stateVersion = "25.05"; # Don't change this unless you know what you're doing!

    ar =
      let
        settings = {
          desktop-environment = "gnome";
          dotdir = config.home.homeDirectory + "/.dotfiles";
          hostName = builtins.baseNameOf ../.;
          fullname = "Aditya Ramanathan";
          email = "dev@adityarama.com";
        };
      in
      {
        backup = {
          enable = true;
          path = "/run/media/${config.home.username}/Seagate Expansion Drive/Linux/backup-${settings.hostName}-${config.home.username}";
          label = "Seagate Expansion Drive";
          name = "Numerical Nexus";
          # shuf -er -n6  {a..f} {0..9} | tr -d '\n'
          # to get a random 6 character hex prefix
          prefix = "e60643-";
          patterns = [
            "R ${config.home.homeDirectory}"
            "- ${config.home.homeDirectory}/Games"
            "- ${config.home.homeDirectory}/.cache"
            "- ${config.home.homeDirectory}/.local/share/Steam/steamapps/common"
          ];
        };
        common = enabled;
        default-apps = enabled;
        freecad = enabled;
        git = {
          enable = true;
          name = settings.fullname;
          email = settings.email;
        };
        games = enabled;
        gnome.enable = settings.desktop-environment == "gnome";
        plasma.enable = settings.desktop-environment == "plasma";
        hw_rgb = enabled;
        musescore = enabled;
        orcaslicer = {
          enable = true;
          pkgsOverride = pkgs-stable;
        };
        rclone = enabled;
        shells = {
          enable = true;
          dotdir = settings.dotdir;
        };
        solaar = enabled;
        syncthing = {
          enable = true;
          proton = {
            enable = true;
            folder = "${config.home.homeDirectory}/Proton";
          };
          obsidian = {
            enable = true;
            folder = "${config.home.homeDirectory}/Documents/Obsidian";
          };
          phonecamera = {
            enable = true;
            folder = "${config.home.homeDirectory}/Pictures/Phone Camera";
          };
          media = {
            enable = true;
            folder = "${config.home.homeDirectory}/Videos/Media";
          };
        };
        vscodium = enabled;
      };

    home.packages = with pkgs; [
      # general productivity
      librewolf
      brave
      protonmail-desktop
      proton-pass
      obsidian
      onlyoffice-desktopeditors
      vlc
      discord
      signal-desktop
      protonvpn-gui
      teams-for-linux

      # coding
      go
      nil
      nixfmt-rfc-style
      python314
      devtoolbox
      android-studio

      # musicy things
      pkgs-stable.audacity
      spotify
      #frescobaldi
      reaper

      # other creative tools
      krita
      flameshot
      inkscape
      kdePackages.kdenlive
      blender

      # other
      qbittorrent
      nomachine-client
      libation
      grayjay
    ];

    home.activation = {
      onlyOfficeCfg =
        mutableDottext ".config/onlyoffice" "DesktopEditors.conf"
          "[General]\nUITheme=theme-dark\nsavePath=${config.home.homeDirectory}/Proton/Documents";
      qbittorrentCfg = mutableDottext ".config/qBittorrent" "qBittorrent.conf" ''
        [BitTorrent]
        Session\GlobalMaxInactiveSeedingMinutes=180
        Session\GlobalMaxRatio=1
        Session\GlobalMaxSeedingMinutes=180
        Session\Interface=proton0
        Session\InterfaceName=proton0
        [LegalNotice]
        Accepted=true
        [Preferences]
        General\Locale=en
        General\PreventFromSuspendWhenDownloading=true
      '';
    };

    home.file = {
      "Templates/New ASCII File".text = "";
      ".local/share/Libation/appsettings.json".text =
        "{\"LibationFiles\": \"${config.home.homeDirectory}/Proton/Music/Libation/\"}";
    };

    systemd.user.targets.user-sleep.Unit.Description = "User pre-sleep target";
    systemd.user.targets.user-wake.Unit.Description = "User post-wake target";
  };
}
