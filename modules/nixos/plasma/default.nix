{
  config,
  lib,
  # pkgs,
  # settings,
  ...
}:
with lib;
with lib.ar;
let
  cfg = config.ar.plasma;
in
{
  options.ar.plasma = {
    enable = mkEnableOption "Enable KDE Plasma Desktop Environmnent";
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
    };

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland = enabled;
    services.desktopManager.plasma6 = enabled;
  };
}
