{
  #config,
  pkgs,
  lib,
  settings,
  inputs,
  ...
}:

{
  imports =
    with lib.lists;
    [
      # Include the results of the hardware scan.
      ./hardware-configuration-hh.nix
      ./proxmox.nix
      ./disk-config-hh.nix
    ]
    ++ (optional (settings.desktop-environment == "gnome") ./desktop-environments/gnome.nix)
    ++ (optional (settings.desktop-environment == "plasma") ./desktop-environments/plasma.nix);

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
    boot = {
      loader = {
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 50;
        efi.canTouchEfiVariables = false; # otherwise installing bootloader fails
        timeout = 1; # Timeout for bootloader menu
      };
    };

    # system.autoUpgrade = {
    #   enable = false;
    #   flake = inputs.self.outPath;
    #   flags = [
    #     "--update-input"
    #     "nixpkgs"
    #     "--commit-lock-file"
    #     "-L" # print build logs
    #   ];
    #   dates = "02:00"; # run daily at 2:00 AM
    #   randomizedDelaySec = "45min";
    # };
    # nix.gc = {
    #   automatic = false;
    #   dates = "01:00"; # run daily at 1:00 AM
    #   options = "--delete-older-than 30d"; # [sudo] nix-collect-garbage
    # };

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      download-buffer-size = 268435456;
      auto-optimise-store = true; # nix store optimise
    };

    networking.hostName = settings.hostname; # Define your hostname.
    networking.hostId = "d8712d14"; # needed for ZFS
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Enable networking
    networking.networkmanager.enable = true;

    # Enable DNS to resolve local hostnames.
    services.resolved.enable = true;
    environment.etc."resolv.conf".source = lib.mkForce "/run/systemd/resolve/resolv.conf";
    networking.enableIPv6 = false;

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

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${settings.username} = {
      isNormalUser = true;
      linger = true;
      description = settings.fullname;
      # shell = pkgs.fish;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    programs.git.enable = true;
    programs.fish.enable = true;

    environment.systemPackages = with pkgs; [
      inputs.agenix.packages.${settings.system}.default
      fastfetch
      tree
      openssl
    ];

    services.vscode-server = {
      enable = true;
      installPath = "$HOME/.vscodium-server";
    };

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

    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [
      8384 # syncthing
      22000 # syncthing
    ];
    networking.firewall.allowedUDPPorts = [
      22000 # syncthing
      21027 # syncthing
    ];

    system.stateVersion = "25.05"; # Don't change this unless you know what you're doing!
  };
}
