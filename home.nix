{
  #config,
  pkgs,
  lib,
  settings,
  ...
}:

{
  imports = [
    ./user/backup.nix
    ./user/gnome.nix
    ./user/hw_rgb.nix
    ./user/syncthing.nix
  ];

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
      mutableDotfile =
        cfgDir: cfgFile: templateFile:
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
            mkdir -p "${settings.homedir}/${cfgDir}"
            cp "${settings.dotdir}/${templateFile}" "${settings.homedir}/${cfgDir}/${cfgFile}"
          fi
        '';
      # mutableDottext =
      #   cfgDir: cfgFile: text:
      #   lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      #     if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
      #       mkdir -p "${settings.homedir}/${cfgDir}"
      #       echo "${text}" > "${settings.homedir}/${cfgDir}/${cfgFile}"
      #     fi
      #   '';
    in
    {
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

      home.activation = {
        freecadUserCfg = mutableDotfile ".config/FreeCAD" "user.cfg" "user/freecad/user.cfg";
      };

      # Home Manager is pretty good at managing dotfiles. The primary way to manage
      # plain files is through 'home.file'.
      home.file = {
        ".config/solaar/config.yaml".source = ./user/solaar/config.yaml;
        ".config/solaar/rules.yaml".source = ./user/solaar/rules.yaml;

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
          "." = "start .";
          rebuildn = "sudo nixos-rebuild switch --flake ${settings.dotdir}";
          rebuildh = "home-manager switch --flake ${settings.dotdir}";
          rebuild = "rebuildn; rebuildh";
          rn = "rebuildn";
          rh = "rebuildh";
          r = "rebuildn; rebuildh";
        };
        bashrcExtra = ''
          start() { nohup nautilus -w $1 >/dev/null 2>&1 & }
        '';
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

      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        profiles.default = {
          extensions = with pkgs.vscode-extensions; [
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
            ms-python.pylint
            ms-python.black-formatter
            ms-python.debugpy
            #msjsdiag.vscode-react-native
            coolbear.systemd-unit-file
            redhat.vscode-yaml
          ];
          userSettings = lib.importJSON ./user/vscodium/settings.json;
        };
      };

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
    };
}
