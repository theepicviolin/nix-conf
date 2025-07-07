{
  config,
  lib,
  pkgs,
  inputs,
  settings,
  ...
}:
let
  mkWgEntry = name: {
    name = "${name}.age";
    value = {
      file = ../secrets/${name}.age;
      path = "/etc/wireguard/${name}.conf";
      name = "${name}.conf";
      mode = "600";
      owner = "root";
      group = "root";
    };
  };
in
{
  options = {
    protonvpn.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = {
    # download confs from https://account.protonvpn.com/downloads
    # add file to secrets/secrets.nix, then
    # agenix -e NEWFILE.age
    age.secrets = builtins.listToAttrs (
      map mkWgEntry [
        "NN-US-UT-182"
        "NN-US-WA-216"
      ]
    );

    environment.systemPackages = [
      inputs.agenix.packages.${settings.system}.default
      pkgs.wireguard-tools
      (pkgs.writeShellScriptBin "vpn" (builtins.readFile ./vpn))
    ];
  };
}
