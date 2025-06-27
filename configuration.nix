{
  #config,
  pkgs,
  #pkgs-stable,
  #lib,
  settings,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./system/sunshine.nix
  ];

  options = {
    # Define options here, e.g.:
    # myOption = mkOption {
    #   type = types.str;
    #   default = "default value";
    #   description = "An example option.";
    # };
  };

  config =
    let
      notifyUserTarget =
        name: delay:
        pkgs.writeShellScript "notify-${name}" ''
          set -e
          _USER="${settings.username}"  # Change if needed
          _UID=$(id -u "$_USER")
          export XDG_RUNTIME_DIR="/run/user/$_UID"

          if loginctl show-user "$_USER" | grep -q "State=active"; then
            sleep ${delay}
            systemctl --user -M "$_USER@" start ${name}.target
          fi
        '';
    in
    {

      # Bootloader.
      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
          timeout = 1; # Timeout for bootloader menu
        };
        plymouth.enable = true;
        kernelParams = [
          "quiet"
          "splash"
        ];
      };

      #boot.loader.grub.enable = true;
      #boot.loader.grub.device = "/dev/nvme0n1";
      #boot.loader.grub.useOSProber = true;

      networking.hostName = settings.hostname; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "America/Los_Angeles";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };

      # Enable the X11 windowing system.
      services.xserver.enable = true;

      # Enable the GNOME Desktop Environment.
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };

      # Enable touchpad support (enabled default in most desktopManager).
      # services.xserver.libinput.enable = true;

      virtualisation.libvirtd.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.${settings.username} = {
        isNormalUser = true;
        linger = true;
        description = settings.fullname;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        #packages = with pkgs; [
        #  thunderbird
        #];
      };

      # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;

      system.autoUpgrade = {
        enable = true;
        flake = inputs.self.outPath;
        flags = [
          "--update-input"
          "nixpkgs"
          "--commit-lock-file"
          "-L" # print build logs
        ];
        dates = "02:00"; # run daily at 2:00 AM
        randomizedDelaySec = "45min";
      };

      systemd.services.disable-gpp0 = {
        enable = true;
        description = "Disable GPP0 to allow system suspending";
        serviceConfig = {
          Type = "simple";
          # wrap this in a shell script instead of executing it directly to avoid some sort of permission issue
          ExecStart = pkgs.writeShellScript "disable-gpp0" "echo 'GPP0' | tee /proc/acpi/wakeup";
        };
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
      };

      systemd.services.user-sleep-hook = {
        description = "Notify user session of sleep";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${notifyUserTarget "user-sleep" "0"} %i";
        };
        wantedBy = [ "sleep.target" ];
        before = [ "sleep.target" ];
      };

      systemd.services.user-wake-hook = {
        description = "Notify user session of wake";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${notifyUserTarget "user-wake" "1"} %i";
        };
        wantedBy = [ "sleep.target" ];
        after = [ "sleep.target" ];
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Startup solaar on boot.
      #hardware.logitech.wireless.enable = true;
      services.solaar.enable = true;

      services.hardware.openrgb.enable = true;
      hardware.spacenavd.enable = true;

      programs.steam.enable = true;
      programs._1password-gui.enable = true;
      programs.thunderbird.enable = true;
      programs.git.enable = true;

      environment.etc = {
        "1password/custom_allowed_browsers" = {
          text = ''
            librewolf
          '';
          mode = "0755";
        };
      };

      nixpkgs.overlays = [ (import ./overlays.nix) ];

      environment.systemPackages = with pkgs; [
        # general productivity
        librewolf
        #_1password-gui
        protonmail-desktop
        proton-pass
        # brave
        #thunderbird
        obsidian
        onlyoffice-desktopeditors
        vlc
        discord
        signal-desktop
        protonvpn-gui
        teams-for-linux

        # coding
        #vscodium
        #git
        go
        nil
        nixfmt-rfc-style
        #python314
        gnome-boxes

        # customizations
        fastfetch
        #solaar
        syncthing
        dconf-editor
        gnome-tweaks

        # musicy things
        audacity
        spotify
        musescore
        frescobaldi
        reaper
        muse-sounds-manager

        # other creative tools
        krita
        flameshot
        inkscape
        #davinci-resolve # this one takes a long time so it can be added later once needed
        blender
        freecad
        orca-slicer

        # games
        prismlauncher

        # other
        qbittorrent
        nomachine-client
        libation
        gparted
      ];

      # Remove unwanted GNOME applications.
      environment.gnome.excludePackages = (
        with pkgs;
        [
          epiphany
          gnome-maps
          geary
          gnome-calendar
          gnome-contacts
          gnome-tour
          gnome-music
          gnome-weather
          gnome-clocks
        ]
      );

      # Remove xterm
      services.xserver.excludePackages = [ pkgs.xterm ];

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      networking.firewall.enable = true;
      networking.firewall.allowedUDPPorts = [
        1900 # orcaslicer
        2021 # orcaslicer
      ];

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.05"; # Did you read the comment?

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.settings.download-buffer-size = 268435456;
    };
}
