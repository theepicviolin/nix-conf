{
  # config,
  lib,
  pkgs,
  # settings,
  ...
}:
{
  options = {
    gnome.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

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
