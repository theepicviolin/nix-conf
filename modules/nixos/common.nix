{
  config,
  pkgs,
  lib,
  hostName,
  inputs,
  flake,
  perSystem,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.common;
in
{
  options.ar.common = {
    enable = mkEnableOption "Common";
    boot = mkEnableOption "Generic systemd boot settings";
    graphicalBoot = mkEnableOption "Show boot splash screen";
    autoUpgrade = mkEnableOption "Automatically update flake daily";
    autoGc = mkEnableOption "Automatically collect garbage daily";
    resolv = mkEnableOption "Resolvd and settings for local hostname dns resolution";
  };

  config = mkIf cfg.enable {
    # Bootloader.
    boot = {
      loader = mkIf cfg.boot {
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 50;
        efi.canTouchEfiVariables = true; # otherwise installing bootloader fails
        timeout = 1; # Timeout for bootloader menu
      };
      plymouth.enable = cfg.graphicalBoot;
      kernelParams = [
        (mkIf cfg.graphicalBoot "quiet")
        (mkIf cfg.graphicalBoot "splash")
      ];
    };

    system.autoUpgrade = {
      enable = cfg.autoUpgrade;
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
    nix.gc = {
      automatic = cfg.autoGc;
      dates = "01:00"; # run daily at 1:00 AM
      options = "--delete-older-than 30d"; # [sudo] nix-collect-garbage
    };

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      download-buffer-size = 268435456;
      auto-optimise-store = true; # nix store optimise
    };

    networking.hostName = hostName;
    nixpkgs.config.allowUnfree = true;

    # networking.hostName = settings.hostname; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Enable networking
    networking.networkmanager = enabled;

    # Enable DNS to resolve local hostnames.
    services.resolved.enable = cfg.resolv;
    environment.etc."resolv.conf".source = mkIf cfg.resolv (
      lib.mkForce "/run/systemd/resolve/resolv.conf"
    );
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

    programs.git = enabled;
    programs.fish = enabled;

    environment.systemPackages = with pkgs; [
      perSystem.agenix.default
      fastfetch
      tree
    ];

    # Enable the OpenSSH daemon.
    services.openssh = enabled;

    networking.firewall = enabled;
  };
}
