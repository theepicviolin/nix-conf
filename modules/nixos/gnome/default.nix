{
  config,
  lib,
  pkgs,
  # settings,
  ...
}:
with lib;
with lib.ar;
let
  cfg = config.ar.gnome;
in
{
  options.ar.gnome = {
    enable = mkEnableOption "Enable GNOME Desktop Environmnent";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
      # Remove xterm
      excludePackages = [ pkgs.xterm ];
    };

    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm = enabled;
    services.desktopManager.gnome = enabled;

    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    environment.systemPackages = [ pkgs.dconf-editor ];

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
  };
}
