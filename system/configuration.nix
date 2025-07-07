{
  #config,
  pkgs,
  #pkgs-stable,
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
      ./hardware-configuration.nix
      ./sunshine.nix
      ./protonvpn.nix
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
      nixpkgs.overlays = [ (import ../overlays/printer.nix) ];

      # Bootloader.
      boot = {
        loader = {
          systemd-boot.enable = true;
          systemd-boot.configurationLimit = 50;
          efi.canTouchEfiVariables = true;
          timeout = 1; # Timeout for bootloader menu
        };
        plymouth.enable = true;
        kernelParams = [
          "quiet"
          "splash"
        ];
      };

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
      nix.gc = {
        automatic = true;
        dates = "01:00"; # run daily at 1:00 AM
        options = "--delete-older-than 30d";
      };

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        download-buffer-size = 268435456;
        auto-optimise-store = true;
      };

      #boot.loader.grub.enable = true;
      #boot.loader.grub.device = "/dev/nvme0n1";
      #boot.loader.grub.useOSProber = true;

      networking.hostName = settings.hostname; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Enable networking
      networking.networkmanager.enable = true;
      networking.interfaces.${settings.ethernet-interface}.wakeOnLan.enable = true; # Enable Wake-on-LAN for the wired interface

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

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;
      services.printing.drivers = [
        pkgs.cups-brother-hll2340dw
      ];

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
      };

      # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;

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

      environment.systemPackages = with pkgs; [
        gparted
        fastfetch
        dconf-editor
        tree
      ];

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

      networking.firewall.enable = true;
      networking.firewall.allowedUDPPorts = [
        1900 # orcaslicer
        2021 # orcaslicer
      ];

      system.stateVersion = "25.05"; # Don't change this unless you know what you're doing!
    };
}
