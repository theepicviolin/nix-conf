{
  #config,
  pkgs,
  # pkgs-stable,
  lib,
  settings,
  ...
}:

{
  imports =
    with lib.lists;
    [
      # ./default-apps.nix
      # ./backup/borgmatic.nix
      # ./games/games.nix
      # ./hw_rgb/hw_rgb.nix
      # ./musescore/musescore.nix
      # ./orcaslicer/orcaslicer.nix
      ./shells/shells.nix
      # ./solaar/solaar.nix
      ./syncthing/syncthing.nix
      # ./vscodium/vscodium.nix
    ]
    ++ (optional (settings.desktop-environment == "gnome") ./desktop-environments/gnome.nix)
    ++ (optional (settings.desktop-environment == "plasma") ./desktop-environments/plasma.nix);

  options = {
    # Define options here, e.g.:
    # myOption = lib.mkOption {
    #   type = lib.types.str;
    #   default = "default value";
    #   description = "An example option.";
    # };
  };

  config =
    # let
    #   utils = {
    #     mutableDotfile =
    #       cfgDir: cfgFile: templateFile:
    #       lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #         if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
    #           mkdir -p "${settings.homedir}/${cfgDir}"
    #           cp "${settings.dotdir}/${templateFile}" "${settings.homedir}/${cfgDir}/${cfgFile}"
    #         fi
    #       '';
    #     mutableDottext =
    #       cfgDir: cfgFile: text:
    #       lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #         if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
    #           mkdir -p "${settings.homedir}/${cfgDir}"
    #           echo "${text}" > "${settings.homedir}/${cfgDir}/${cfgFile}"
    #         fi
    #       '';
    #     replaceFile =
    #       cfgDir: cfgFile: file:
    #       lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #         if [ -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
    #           if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}.bak" ]; then
    #             mv "${settings.homedir}/${cfgDir}/${cfgFile}" "${settings.homedir}/${cfgDir}/${cfgFile}.bak"
    #           fi
    #           cp "${settings.dotdir}/${file}" "${settings.homedir}/${cfgDir}/${cfgFile}"
    #           chmod 755 "${settings.homedir}/${cfgDir}/${cfgFile}"
    #         fi
    #       '';

    #     mimeToAppMap =
    #       appMimeMap:
    #       (builtins.foldl' (
    #         acc: app:
    #         acc
    #         // builtins.listToAttrs (
    #           map (mime: {
    #             name = mime;
    #             value = [ app ];
    #           }) appMimeMap.${app}
    #         )
    #       ) { } (builtins.attrNames appMimeMap));
    #   };
    # in
    {
      # orcaslicer = { inherit utils; };
      # default-apps = { inherit utils; };
      # games = { inherit utils; };
      # nixpkgs.overlays = [ (import ../overlays/frescobaldi.nix) ];
      home.username = settings.username;
      home.homeDirectory = settings.homedir;

      home.stateVersion = "25.05"; # Don't change this unless you know what you're doing!

      nixpkgs.config.allowUnfree = true;

      home.packages = [
        # general productivity
        # librewolf
        # brave
        # protonmail-desktop
        # proton-pass
        # obsidian
        # onlyoffice-desktopeditors
        # vlc
        # discord
        # signal-desktop
        # protonvpn-gui
        # teams-for-linux

        # coding
        # go
        # nil
        # nixfmt-rfc-style
        # python314
        # devtoolbox
        # android-studio

        # musicy things
        # audacity
        # spotify
        #frescobaldi
        # reaper

        # other creative tools
        # krita
        # flameshot
        # inkscape
        # kdePackages.kdenlive
        # blender
        # pkgs-stable.freecad

        # other
        # qbittorrent
        # nomachine-client
        # libation
        # grayjay
      ];

      home.activation = {
        # freecadUserCfg = utils.mutableDotfile ".config/FreeCAD" "user.cfg" "user/freecad/user.cfg";
        # onlyOfficeCfg =
        #   utils.mutableDottext ".config/onlyoffice" "DesktopEditors.conf"
        #     "[General]\nUITheme=theme-dark\nsavePath=${settings.homedir}/Proton/Documents";
        # qbittorrentCfg = utils.mutableDottext ".config/qBittorrent" "qBittorrent.conf" ''
        #   [BitTorrent]
        #   Session\GlobalMaxInactiveSeedingMinutes=180
        #   Session\GlobalMaxRatio=1
        #   Session\GlobalMaxSeedingMinutes=180
        #   Session\Interface=proton0
        #   Session\InterfaceName=proton0
        #   [LegalNotice]
        #   Accepted=true
        #   [Preferences]
        #   General\Locale=en
        #   General\PreventFromSuspendWhenDownloading=true
        # '';
      };

      home.file = {
        # "Templates/New ASCII File".text = "";
        # ".local/share/Libation/appsettings.json".text =
        #   "{\"LibationFiles\": \"${settings.homedir}/Proton/Music/Libation/\"}";
      };

      home.sessionVariables = {
        # EDITOR = "emacs";
      };

      # systemd.user.targets.user-sleep.Unit.Description = "User pre-sleep target";
      # systemd.user.targets.user-wake.Unit.Description = "User post-wake target";

      programs.git = {
        enable = true;
        userName = settings.fullname;
        userEmail = settings.email;
        aliases = {
          s = "status";
        };
        extraConfig = {
          credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
          init = {
            defaultBranch = "main";
          };
          push = {
            autoSetupRemote = true;
          };
          pull = {
            rebase = true;
          };
        };
      };

      programs.rclone = {
        enable = true;
      };

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
    };
}
