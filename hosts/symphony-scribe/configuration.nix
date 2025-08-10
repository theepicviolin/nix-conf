{
  pkgs,
  lib,
  hostName,
  flake,
  inputs,
  ...
}:
with flake.lib;
{
  imports = [ 
    nixos-wsl.nixosModules.default
  ]
  ++ lib.attrsets.attrValues flake.nixosModules
  ++ lib.attrsets.attrValues flake.modules.common;

  home-manager.users = lib.mkForce { }; # use standalone home-manager

  networking.hostName = hostName;

  ar =
    let
      settings = {
        desktop-environment = "";
      };
    in
    {
      # common = {
      #   enable = true;
      #   graphicalBoot = true;
      #   autoUpgrade = true;
      #   autoGc = true;
      # };
      # _1password = enabled;
      # sunshine = {
      #   enable = true;
      #   displayname = "Numerical Nexus";
      # };
      # protonvpn = enabled;
      # virtualisation = enabled;
      # printer = enabled;
      # sound = enabled;
      # gnome.enable = (settings.desktop-environment == "gnome");
      # plasma.enable = (settings.desktop-environment == "plasma");
    };

    wsl.enable = true;
    wsl.defaultUser = "aditya";

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      download-buffer-size = 268435456;
    };


    nixpkgs.config.allowUnfree = true;

    # networking.hostName = settings.hostname; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Enable networking
    networking.networkmanager = enabled;

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
      fastfetch
      tree
    ];

  # Enable the OpenSSH daemon.
  services.openssh = enabled;

  # users.users.aditya = {
  #   isNormalUser = true;
  #   linger = true;
  #   description = "Aditya Ramanathan";
  #   shell = pkgs.fish;
  #   extraGroups = [
  #     "networkmanager"
  #     "wheel"
  #   ];
  # };

  environment.systemPackages = with pkgs; [
    openssl
  ];

  system.stateVersion = "25.11"; # Don't change this unless you know what you're doing!
}
