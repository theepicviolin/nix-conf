{ config, pkgs, lib, ... }:

{
  options = {
    wallpaper = lib.mkOption {
      type = lib.types.str;
      default = config.home.homeDirectory + "/.dotfiles/wallpaper.jpg";
      description = "Path to the wallpaper image.";
    };
  };

  config = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home.username = "aditya";
    home.homeDirectory = "/home/aditya";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "25.05"; # Please read the comment before changing.


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
      userName = "Aditya Ramanathan";
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
        move-to-workspace-left = ["<Shift><Control><Alt><Super>Return"];
        move-to-workspace-right = ["<Shift><Control><Alt>Return"];
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
      };

      
      "org/gnome/desktop/background" = {
        picture-uri = "file://" + config.wallpaper;
        picture-uri-dark = "file://" + config.wallpaper;
        color-shading-type = "solid";
        primary-color = "#77767B";
        secondary-color = "#000000";
        picture-options = "zoom";
      };

      "org/gnome/desktop/screensaver" = {
        color-shading-type = "solid";
        picture-uri = "file://" + config.wallpaper;
        primary-color = "#77767B";
        secondary-color = "#000000";
        picture-options = "zoom";
      };

      "org/gnome/desktop/notifications" = {
        show-in-lock-screen = false;
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

      "org/gnome/shell/extensions/advanced-alttab-window-switcher" = {
        app-switcher-popup-fav-apps = false;
        app-switcher-popup-filter = 2;
        app-switcher-popup-include-show-apps-icon = false;
        app-switcher-popup-titles = true;
        app-switcher-popup-win-counter = false;
        switcher-popup-preview-selected = 2;
        switcher-popup-scroll-in = 1;
        switcher-popup-scroll-out = 1;
        switcher-popup-start-search = false;
        win-switcher-popup-filter = 2;
        win-switcher-popup-scroll-item = 1;
        win-switcher-popup-search-apps = false;
      };

      "org/gnome/shell/extensions/appindicator" = {
        icon-saturation = 1;
        custom-icons = [ (mkTuple ["indicator-solaar" "/home/aditya/Pictures/solaaricon.png" ""]) ];
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
