{
  inputs,
  config,
  lib,
  pkgs,
  settings,
  ...
}:
let

in
{
  options = {
    ssh.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = with config.ssh; {
    home.activation.generateSSHKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        mkdir -p "$HOME/.ssh"
        ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
        echo "Generated SSH key for $USER"
      fi
    '';
  };
}
