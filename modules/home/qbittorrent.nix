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
  cfg = config.ar.qbittorrent;
in
{
  options.ar.qbittorrent = {
    enable = mkEnableOption "Enable and configure qBittorrent";
  };

  config = mkIf cfg.enable {
    home.activation = {
      qbittorrentCfg = mutableDottext ".config/qBittorrent/qBittorrent.conf" ''
        [BitTorrent]
        Session\GlobalMaxInactiveSeedingMinutes=180
        Session\GlobalMaxRatio=1
        Session\GlobalMaxSeedingMinutes=180
        Session\Interface=proton0
        Session\InterfaceName=proton0
        [LegalNotice]
        Accepted=true
        [Preferences]
        General\Locale=en
        General\PreventFromSuspendWhenDownloading=true
      '';
    };

    home.packages = [ pkgs.qbittorrent ];
  };
}
