{
  inputs,
  config,
  lib,
  pkgs,
  flake,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.ar.ssh;
in
{
  options.ar.ssh = {
    enable = mkEnableOption "Autogenerate user ssh keys";
  };

  config = mkIf cfg.enable {
    home.activation.generateSSHKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        mkdir -p "$HOME/.ssh"
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
      fi
    '';
  };
}
