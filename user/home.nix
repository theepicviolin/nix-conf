{
  #config,
  pkgs,
  lib,
  settings,
  ...
}:

{
  imports =
    with lib.lists;
    [
      ./default-apps.nix
      ./backup/borgmatic.nix
      ./hw_rgb/hw_rgb.nix
      ./musescore/musescore.nix
      ./orcaslicer/orcaslicer.nix
      ./solaar/solaar.nix
      ./syncthing/syncthing.nix
      ./vscodium/vscodium.nix
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
    let
      utils = {
        mutableDotfile =
          cfgDir: cfgFile: templateFile:
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
              mkdir -p "${settings.homedir}/${cfgDir}"
              cp "${settings.dotdir}/${templateFile}" "${settings.homedir}/${cfgDir}/${cfgFile}"
            fi
          '';
        mutableDottext =
          cfgDir: cfgFile: text:
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
              mkdir -p "${settings.homedir}/${cfgDir}"
              echo "${text}" > "${settings.homedir}/${cfgDir}/${cfgFile}"
            fi
          '';
        mimeToAppMap =
          appMimeMap:
          (builtins.foldl' (
            acc: app:
            acc
            // builtins.listToAttrs (
              map (mime: {
                name = mime;
                value = [ app ];
              }) appMimeMap.${app}
            )
          ) { } (builtins.attrNames appMimeMap));
      };
    in
    {
      orcaslicer = { inherit utils; };
      default-apps = { inherit utils; };
      nixpkgs.overlays = [ (import ../overlays/frescobaldi.nix) ];
      home.username = settings.username;
      home.homeDirectory = settings.homedir;

      home.stateVersion = "25.05"; # Don't change this unless you know what you're doing!

      nixpkgs.config.allowUnfree = true;

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
        gnome-boxes

        # musicy things
        audacity
        spotify
        frescobaldi
        reaper

        # other creative tools
        krita
        flameshot
        inkscape
        #davinci-resolve # this one takes a long time so it can be added later once needed
        blender
        freecad

        # games
        prismlauncher

        # other
        qbittorrent
        nomachine-client
        libation
      ];

      home.activation = {
        freecadUserCfg = utils.mutableDotfile ".config/FreeCAD" "user.cfg" "user/freecad/user.cfg";
      };

      home.file = {
        ".local/share/Libation/appsettings.json".text =
          "{\"LibationFiles\": \"${settings.homedir}/Proton/Music/Libation/\"}";
      };

      home.sessionVariables = {
        # EDITOR = "emacs";
      };

      programs.bash = {
        enable = true;
        shellAliases = {
          md = "mkdir";
          "." = "start .";
          rebuildn = "sudo nixos-rebuild switch --flake ${settings.dotdir}";
          rebuildh = "home-manager switch --flake ${settings.dotdir}";
          rebuild = "rebuildn; rebuildh";
          rn = "rebuildn";
          rh = "rebuildh";
          r = "rebuildn; rebuildh";
          start = "xdg-open";
        };
      };

      systemd.user.services.steam = {
        Unit = {
          Description = "Open Steam in the background at boot";
        };
        Service = {
          ExecStartPre = "/usr/bin/env sleep 1";
          ExecStart = "${pkgs.steam}/bin/steam -nochatui -nofriendsui -silent %U";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      systemd.user.targets.user-sleep.Unit.Description = "User pre-sleep target";
      systemd.user.targets.user-wake.Unit.Description = "User post-wake target";

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
