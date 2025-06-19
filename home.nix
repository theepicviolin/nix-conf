{ config, pkgs, lib, settings, ... }:

{
  options = {
    # Define options here, e.g.:
    # myOption = lib.mkOption {
    #   type = lib.types.str;
    #   default = "default value";
    #   description = "An example option.";
    # };
  };

  config = {
    home.username = settings.username; 
    home.homeDirectory = settings.homedir;

    home.stateVersion = "25.05"; # Don't change this unless you know what you're doing!

    nixpkgs.config.allowUnfree = true;

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = [
      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file = {
      ".config/solaar/config.yaml".source = ./solaar/config.yaml;
      ".config/solaar/rules.yaml".source = ./solaar/rules.yaml;
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/aditya/etc/profile.d/hm-session-vars.sh
    #
    home.sessionVariables = {
      # EDITOR = "emacs";
    };

    programs.bash = {
      enable = true;
      shellAliases = {
        md = "mkdir";
        ll = "ls -l";
        "." = "start .";
        rebuildn = "sudo nixos-rebuild switch --flake ~/.dotfiles";
        rebuildh = "home-manager switch --flake ~/.dotfiles";
        rebuild = "rebuildn; rebuildh";
      };
      bashrcExtra = ''
        start() { nohup nautilus -w $1 >/dev/null 2>&1 & }
      '';
    };

    programs.git = {
      enable = true;
      userName = settings.fullname;
      userEmail = "adit99@live.com";
      extraConfig = {
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

    services.syncthing = {
      enable = true;
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        folders = {
          "${settings.homedir}/Proton" = {
            label = "Proton Drive";
            id = "vhwys-cspch";
            devices = [ "Harmony Host" ];
          };
          "${settings.homedir}/Documents/Obsidian" = {
            label = "Obsidian";
            id = "txpxx-3pgud";
            devices = [ "Cosmic Communicator" "Symphony Scribe" "Gaming Gateway" "Harmony Host" ];
          };

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
      };
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        #atlassian.atlascode
        #synedra.auto-run-command
        dbaeumer.vscode-eslint
        github.copilot
        eamodio.gitlens
        golang.go
        haskell.haskell
        justusadam.language-haskell
        jnoortheen.nix-ide
        esbenp.prettier-vscode
        mads-hartmann.bash-ide-vscode
        ms-python.python
        ms-python.debugpy
        #msjsdiag.vscode-react-native
        coolbear.systemd-unit-file
        redhat.vscode-yaml
      ];
    };

    dconf.enable = true;
    dconf.settings = with lib.hm.gvariant;{
      # Gnome Settings

      "org/gnome/shell" = {
        favorite-apps = [
          "librewolf.desktop"
          "org.gnome.Nautilus.desktop"
          "thunderbird.desktop"
          "obsidian.desktop"
          "discord.desktop"
          "codium.desktop"
          "org.freecad.FreeCAD.desktop"
          "OrcaSlicer.desktop"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" 
                              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"];
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
      "org/gnome/settings-daemon/plugins/media-keys" = {
        home = ["<Super>e"];
      };
      "org/gnome/shell/keybindings" = {
        toggle-message-tray = ["<Super>c"];
      };

      "org/gnome/desktop/wm/keybindings" = {
        move-to-workspace-left = ["<Shift><Control><Alt><Super>Return"];
        move-to-workspace-right = ["<Shift><Control><Alt>Return"];
        switch-windows = ["<Alt>Tab"];
        switch-windows-backward = ["<Shift><Alt>Tab"];
        switch-applications = ["<Super>Tab"];
        switch-applications-backward = ["<Shift><Super>Tab"];
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      "org/gnome/desktop/session" = {
        idle-delay = mkUint32 600; # 10 minutes
      };

      "org/gnome/mutter" = {
        workspaces-only-on-primary = false;
      };

      "org/gnome/desktop/interface" = {
        accent-color = "purple";
        clock-format = "12h";
      };

      "org/gnome/desktop/background" = {
        picture-uri = "file://" + settings.wallpaper;
        picture-uri-dark = "file://" + settings.wallpaper;
        color-shading-type = "solid";
        primary-color = "#77767B";
        secondary-color = "#000000";
        picture-options = "zoom";
      };

      "org/gnome/desktop/screensaver" = {
        color-shading-type = "solid";
        picture-uri = "file://" + settings.wallpaper;
        primary-color = "#77767B";
        secondary-color = "#000000";
        picture-options = "zoom";
      };

      "org/gnome/desktop/notifications" = {
        show-in-lock-screen = false;
      };

      "org/gnome/nautilus/icon-view" = {
        default-zoom-level = "small-plus";
      };

      "org/gtk/settings/file-chooser" = {
        clock-format = "12h";
      };

      "ca/desrt/dconf-editor" = {
        show-warning = false;
      };

      # Gnome Shell Extensions 
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          advanced-alttab-window-switcher.extensionUuid
          appindicator.extensionUuid
          bluetooth-quick-connect.extensionUuid
          blur-my-shell.extensionUuid
          caffeine.extensionUuid
          custom-hot-corners-extended.extensionUuid
          clipboard-indicator.extensionUuid
          color-picker.extensionUuid
          fullscreen-avoider.extensionUuid
          just-perfection.extensionUuid
          rounded-window-corners-reborn.extensionUuid
          search-light.extensionUuid
          syncthing-toggle.extensionUuid
          unblank.extensionUuid
        ];
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
        icon-saturation = 1;
        custom-icons = [ (mkTuple ["indicator-solaar" "${settings.dotdir}/solaar/icon.png" ""]) ];
      };

      "org/gnome/shell/extensions/bluetooth-quick-connect" = {
        show-battery-value-on = true;
      };

      "org/gnome/shell/extensions/caffeine" = {
        duration-timer-list=[1800 3600 7200]; # 30 minutes, 1 hour, 2 hours
        use-custom-duration=true;
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
        toggle-menu = ["<Super>v"];
      };

      "org/gnome/shell/extensions/color-picker" = {
        color-picker-shortcut = ["<Shift><Super>c"];
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
        animation-speed = 100.0;
        background-color = mkTuple [0.1 0.1 0.1 0.8];
        blur-brightness=0.6;
        blur-sigma=30.0;
        border-radius=1;
        entry-font-size=1;
        preferred-monitor=0;
        scale-height=0.1;
        scale-width=0.1;
        shortcut-search=["<Control>space"];
      };

      "org/gnome/shell/extensions/unblank" = {
        time = 300;
      };
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
