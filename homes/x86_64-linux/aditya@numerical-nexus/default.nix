{
  config,
  pkgs,
  pkgs-stable,
  lib,
  settings,
  host,
  inputs,
  ...
}:
with lib;
with lib.ar;
{
  config = {
    # nixpkgs.overlays = [ (import ../overlays/frescobaldi.nix) ];
    # home.username = settings.username;
    # home.homeDirectory = settings.homedir;

    home.stateVersion = "25.05"; # Don't change this unless you know what you're doing!

    ar = {
      backup = {
        enable = true;
        path = "/run/media/${settings.username}/Seagate Expansion Drive/Linux/backup-${host}-${settings.username}";
        label = "Seagate Expansion Drive";
        # shuf -er -n6  {a..f} {0..9} | tr -d '\n'
        # to get a random 6 character hex prefix
        prefix = "e60643-";
        patterns = [
          "R ${settings.homedir}"
          "- ${settings.homedir}/Games"
          "- ${settings.homedir}/.cache"
          "- ${settings.homedir}/.local/share/Steam/steamapps/common"
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
          folder = "${settings.homedir}/Proton";
        };
        obsidian = {
          enable = true;
          folder = "${settings.homedir}/Documents/Obsidian";
        };
        phonecamera = {
          enable = true;
          folder = "${settings.homedir}/Pictures/Phone Camera";
        };
        media = {
          enable = true;
          folder = "${settings.homedir}/Videos/Media";
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
          "[General]\nUITheme=theme-dark\nsavePath=${settings.homedir}/Proton/Documents";
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
        "{\"LibationFiles\": \"${settings.homedir}/Proton/Music/Libation/\"}";
    };

    systemd.user.targets.user-sleep.Unit.Description = "User pre-sleep target";
    systemd.user.targets.user-wake.Unit.Description = "User post-wake target";
  };
}
