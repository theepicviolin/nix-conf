{
  config,
  lib,
  pkgs,
  inputs,
  flake,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.printer;
in
{
  options.ar.printer = {
    enable = mkEnableOption "Enable printing from the Brother printer";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ (import ../../overlays/printer.nix) ];

    # Enable CUPS to print documents.
    services.printing = {
      enable = true;
      drivers = [
        pkgs.cups-brother-hll2340dw
        pkgs.brlaser
        pkgs.brgenml1lpr
        pkgs.brgenml1cupswrapper
      ];
    };

    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    services.avahi.openFirewall = true;
  };
}
