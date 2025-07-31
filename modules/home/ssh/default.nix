{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.ar;
let
  cfg = config.ar.ssh;
in
{
  options.ar.ssh = {
    enable = mkEnableOption "Autogenerate user ssh keys";
  };

  config = mkIf cfg.enable {
    home.activation.generateSSHKey = lib.home-manager.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        mkdir -p "$HOME/.ssh"
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
      fi
    '';
  };
}
