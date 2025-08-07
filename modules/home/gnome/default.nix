{
  config,
  lib,
  pkgs,
  # settings,
  ...
}:
with lib;
let
  cfg = config.ar.gnome;
  extensions = with pkgs.gnomeExtensions; [
    advanced-alttab-window-switcher
    appindicator
    bluetooth-quick-connect
    blur-my-shell
    caffeine
    custom-hot-corners-extended
    clipboard-indicator
    color-picker
    fullscreen-avoider
    just-perfection
    rounded-window-corners-reborn
    search-light
    syncthing-toggle
    unblank
  ];

  apl-entry =
    with lib.hm.gvariant;
    name:
    (
      position:
      (mkDictionaryEntry [
        name
        (mkVariant [
          (mkDictionaryEntry [
            "position"
            (mkVariant position)
          ])
        ])
      ])
    );
  dash = [
    "librewolf.desktop"
    "org.gnome.Nautilus.desktop"
    "proton-mail.desktop"
    "obsidian.desktop"
    "discord.desktop"
    "codium.desktop"
    "org.freecad.FreeCAD.desktop"
    "OrcaSlicer.desktop"
  ];
  # dconf read /org/gnome/shell/app-picker-layout
  # to see the current layout

  # ls ~/.nix-profile/share/applications          # Home Manager applications
  # ls /run/current-system/sw/share/applications  # System applications
  # ls ~/.local/share/applications                # Steam games

  app-layout = [
    [
      "1password.desktop"
      "org.gnome.SystemMonitor.desktop"
      "org.gnome.Settings.desktop"
      "org.gnome.Console.desktop"
      "org.gnome.Extensions.desktop"
      "org.gnome.Calculator.desktop"
      "thunderbird.desktop"
      "proton-pass.desktop"
      "protonvpn-app.desktop"
      "teams-for-linux.desktop"
      "onlyoffice-desktopeditors.desktop"
      "org.musescore.MuseScore.desktop"
      "org.frescobaldi.Frescobaldi.desktop"
      "audacity.desktop"
      "cockos-reaper.desktop"
      "org.kde.kdenlive.desktop"
      "blender.desktop"
      "org.inkscape.Inkscape.desktop"
      "org.kde.krita.desktop"
      "org.flameshot.Flameshot.desktop"
      "libation.desktop"
      "spotify.desktop"
      "steam.desktop"
      "Games"
    ]
    (
      # Do this to sort by display name
      (builtins.attrValues {
        AndroidStudio = "android-studio.desktop";
        Boxes = "org.gnome.Boxes.desktop";
        Brave = "brave-browser.desktop";
        DconfEditor = "ca.desrt.dconf-editor.desktop";
        DevToolbox = "me.iepure.devtoolbox.desktop";
        DiskUsageAnalyzer = "org.gnome.baobab.desktop";
        Fish = "fish.desktop";
        Gparted = "gparted.desktop";
        Grayjay = "Grayjay.desktop";
        Lutris = "net.lutris.Lutris.desktop";
        MuseSoundsManager = "muse-sounds-manager.desktop";
        NoMachine = "NoMachine-player-base.desktop";
        OpenRGB = "OpenRGB.desktop";
        QBittorrent = "org.qbittorrent.qBittorrent.desktop";
        Signal = "signal.desktop";
        Solaar = "solaar.desktop";
        Sunshine = "dev.lizardbyte.app.Sunshine.desktop";
        Syncthing = "syncthing-ui.desktop";
        TextEditor = "org.gnome.TextEditor.desktop";
        Tweaks = "org.gnome.tweaks.desktop";
        VirtualMachineManager = "virt-manager.desktop";
        VLC = "vlc.desktop";
      })
      ++ [ "Other" ]
    )
  ];
  folders = {
    Games = builtins.sort builtins.lessThan [
      "Dust An Elysian Tail.desktop"
      "Filament.desktop"
      "Golf With Your Friends.desktop"
      "South Park The Stick of Truth.desktop"
      "Stray.desktop"
      "The Talos Principle.desktop"
      "TUNIC.desktop"
      "Viewfinder.desktop"
      "org.prismlauncher.PrismLauncher.desktop"
      "Baba Is You.desktop"
      "Blue Prince.desktop"
      "Crypt of the NecroDancer.desktop"
      "DELTARUNE.desktop"
      "Celeste.desktop"
      "Divinity Original Sin Enhanced Edition.desktop"
      "Antichamber.desktop"
      "GRIS.desktop"
    ];
    Other = [
      "org.gnome.Connections.desktop"
      "org.gnome.Evince.desktop"
      "org.gnome.FileRoller.desktop"
      "org.gnome.font-viewer.desktop"
      "org.gnome.Loupe.desktop"
      "org.gnome.DiskUtility.desktop"
      "org.gnome.Logs.desktop"
      "org.gnome.Characters.desktop"
      "org.gnome.Decibels.desktop"
      "nixos-manual.desktop"
      "cups.desktop"
      "org.gnome.seahorse.Application.desktop"
      "yelp.desktop"
      "simple-scan.desktop"
      "org.gnome.Totem.desktop"
      "org.gnome.Snapshot.desktop"
    ];
  };

  wallpaper = "file://" + builtins.toString ./wallpaper.png;
in
{
  options.ar.gnome = {
    enable = mkEnableOption "Configure custom GNOME settings";
  };

  config = mkIf cfg.enable {
    home.packages = extensions ++ [ pkgs.gnome-tweaks ]; # merges with packages from home.nix

    home.file = {
      ".face".source = ./R.png; # gnome profile picture
      ".background-image".source = ./wallpaper.png; # wallpaper (I don't think this does anything but it might help the wallpaper to not get GC'ed)
    };

    dconf.enable = true;

    dconf.settings =
      with lib.hm.gvariant;
      (lib.attrsets.concatMapAttrs (thisName: thisApps: ({
        "org/gnome/desktop/app-folders/folders/${thisName}" = {
          apps = thisApps;
          name = thisName;
        };
      })) folders)
      // {
        "org/gnome/desktop/app-folders" = {
          folder-children = lib.attrNames folders;
        };

        "org/gnome/desktop/background" = {
          picture-uri = wallpaper;
          picture-uri-dark = wallpaper;
          color-shading-type = "solid";
          primary-color = "#77767B";
          secondary-color = "#000000";
          picture-options = "zoom";
        };

        "org/gnome/desktop/interface" = {
          accent-color = "purple";
          clock-format = "12h";
          color-scheme = "prefer-dark";
          clock-show-weekday = true;
        };

        "org/gnome/desktop/notifications" = {
          show-in-lock-screen = false;
        };

        "org/gnome/desktop/screensaver" = {
          color-shading-type = "solid";
          picture-uri = wallpaper;
          primary-color = "#77767B";
          secondary-color = "#000000";
          picture-options = "zoom";
        };

        "org/gnome/desktop/session" = {
          idle-delay = mkUint32 900; # 15 minutes
        };

        "org/gnome/desktop/wm/keybindings" = {
          move-to-workspace-left = [ "<Shift><Control><Alt><Super>Return" ];
          move-to-workspace-right = [ "<Shift><Control><Alt>Return" ];
          switch-windows = [ "<Alt>Tab" ];
          switch-windows-backward = [ "<Shift><Alt>Tab" ];
          switch-applications = [ "<Super>Tab" ];
          switch-applications-backward = [ "<Shift><Super>Tab" ];
        };

        "org/gnome/gnome-session" = {
          logout-prompt = false;
        };

        "org/gnome/mutter" = {
          workspaces-only-on-primary = false;
        };

        "org/gnome/nautilus/icon-view" = {
          default-zoom-level = "small-plus";
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          ];
          home = [ "<Super>e" ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>t";
          command = "kgx";
          name = "Launch Console Super+T";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Ctrl><Alt>t";
          command = "kgx";
          name = "Launch Console Ctrl+Alt+T";
        };

        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-timeout = mkUint32 900; # 15 minutes
        };

        "org/gnome/shell" = {
          favorite-apps = dash;
          app-picker-layout = map (page: (lib.lists.imap0 (idx: name: (apl-entry name idx)) page)) app-layout;
        };

        "org/gnome/shell/keybindings" = {
          toggle-message-tray = [ "<Super>c" ];
        };

        "org/gtk/settings/file-chooser" = {
          clock-format = "12h";
        };

        "ca/desrt/dconf-editor" = {
          show-warning = false;
        };

        ######################################
        ####### GNOME SHELL EXTENSIONS #######
        ######################################
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = map (ext: ext.extensionUuid) extensions;
        };

        "org/gnome/shell/extensions/advanced-alt-tab-window-switcher" = {
          app-switcher-popup-fav-apps = false;
          app-switcher-popup-filter = 2;
          app-switcher-popup-include-show-apps-icon = false;
          app-switcher-popup-titles = true;
          app-switcher-popup-win-counter = false;
          switcher-popup-preview-selected = 2;
          switcher-popup-scroll-in = 1;
          switcher-popup-scroll-out = 1;
          switcher-popup-start-search = false;
          win-switcher-popup-filter = 1;
          win-switcher-popup-scroll-item = 1;
          win-switcher-popup-search-apps = false;
        };

        "org/gnome/shell/extensions/appindicator" = {
          #icon-saturation = 1;
        };

        "org/gnome/shell/extensions/bluetooth-quick-connect" = {
          show-battery-value-on = true;
        };

        "org/gnome/shell/extensions/caffeine" = {
          duration-timer-list = [
            1800
            3600
            7200
          ]; # 30 minutes, 1 hour, 2 hours
          use-custom-duration = true;
        };

        "org/gnome/shell/extensions/custom-hot-corners-extended/misc" = {
          panel-menu-enable = false;
        };
        "org/gnome/shell/extensions/custom-hot-corners-extended/monitor-0-bottom-left-0" = {
          action = "show-applications";
        };
        "org/gnome/shell/extensions/custom-hot-corners-extended/monitor-0-top-left-0" = {
          action = "toggle-overview";
        };

        "org/gnome/shell/extensions/clipboard-indicator" = {
          display-mode = 3;
          toggle-menu = [ "<Super>v" ];
        };

        "org/gnome/shell/extensions/color-picker" = {
          color-picker-shortcut = [ "<Shift><Super>c" ];
          enable-notify = true;
          enable-shortcut = true;
          enable-sound = false;
          enable-systray = false;
          notify-style = mkUint32 1;
        };

        "org/gnome/shell/extensions/fullscreen-avoider" = {
          move-hot-corners = false;
          move-notifications = false;
        };

        "org/gnome/shell/extensions/just-perfection" = {
          accessibility-menu = true;
          animation = 4;
          clock-menu = true;
          keyboard-layout = true;
          quick-settings-dark-mode = false;
          quick-settings-night-light = false;
          startup-status = 0;
          support-notifier-showed-version = 34;
          support-notifier-type = 0;
          switcher-popup-delay = false;
          theme = true;
          window-demands-attention-focus = true;
        };

        "org/gnome/shell/extensions/search-light" = {
          background-color = mkTuple [
            0.1
            0.1
            0.1
            0.8
          ];
          border-radius = 1.0;
          shortcut-search = [ "<Control>space" ];
        };

        "org/gnome/shell/extensions/unblank" = {
          time = 300;
        };
      };
  };
}
