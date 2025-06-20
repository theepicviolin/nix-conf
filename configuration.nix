{
  config,
  pkgs,
  lib,
  settings,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  options = {
    # Define options here, e.g.:
    # myOption = mkOption {
    #   type = types.str;
    #   default = "default value";
    #   description = "An example option.";
    # };
  };

  config = {

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

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

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${settings.username} = {
      isNormalUser = true;
      description = settings.fullname;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [
        #  thunderbird
      ];
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
        ExecStart = ./disable-gpp0.sh;
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
    };

    # Startup solaar on boot.
    #hardware.logitech.wireless.enable = true;
    services.solaar.enable = true;

    # Install firefox.
    programs.firefox.enable = false;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Install steam.
    programs.steam.enable = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      # general productivity
      librewolf
      _1password-gui
      protonmail-desktop
      # brave
      thunderbird
      obsidian
      onlyoffice-desktopeditors
      vlc
      discord
      signal-desktop
      protonvpn-gui

      # coding
      vscodium
      git
      go
      nil
      nixfmt-rfc-style

      # customizations
      fastfetch
      #solaar
      openrgb
      syncthing
      dconf-editor
      gnome-tweaks
      gnomeExtensions.advanced-alttab-window-switcher
      gnomeExtensions.appindicator
      gnomeExtensions.bluetooth-quick-connect
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.custom-hot-corners-extended
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.color-picker
      gnomeExtensions.fullscreen-avoider
      gnomeExtensions.just-perfection
      gnomeExtensions.rounded-window-corners-reborn
      gnomeExtensions.search-light
      gnomeExtensions.syncthing-toggle
      gnomeExtensions.unblank

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
      # davinci-resolve #  this one takes a long time so it can be added later once needed
      blender
      freecad
      orca-slicer

      # games
      prismlauncher
      sunshine

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
    networking.firewall.enable = false;

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
