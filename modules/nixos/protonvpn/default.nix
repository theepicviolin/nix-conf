{
  config,
  lib,
  pkgs,
  inputs,
  settings,
  secretsdir,
  ...
}:

with lib;
with lib.ar;
let
  cfg = config.ar.protonvpn;

  mkWgEntry = name: {
    name = "${name}.age";
    value = {
      file = secretsdir + "/${name}.age";
      path = "/etc/wireguard/${name}.conf";
      name = "${name}.conf";
      mode = "600";
      owner = "root";
      group = "root";
    };
  };
in
{
  options.ar.protonvpn = {
    enable = mkEnableOption "Enable custom Proton VPN command line tool (in case GUI app doesn't work)";
  };

  config = mkIf cfg.enable {
    # download confs from https://account.protonvpn.com/downloads
    # add file to secrets/secrets.nix, then
    # agenix -e NEWFILE.age
    age.secrets = builtins.listToAttrs (
      map mkWgEntry [
        "NN-US-UT-47"
        "NN-US-UT-139"
        "NN-US-UT-182"
        "NN-US-WA-206"
        "NN-US-WA-216"
        "NN-CA-1150"
      ]
    );

    environment.systemPackages = with pkgs; [
      wireguard-tools
      (writeShellScriptBin "vpn" (builtins.readFile ./vpn))
      bc
    ];

    environment.etc."bash_completion.d/vpn".text = ''
      _vpn_completions() {
        local cur prev commands vpn_names matches
        COMPREPLY=()
        cur="''${COMP_WORDS[COMP_CWORD]}"
        prev="''${COMP_WORDS[COMP_CWORD-1]}"
        commands="list on off up down"

        if [[ $COMP_CWORD -eq 1 ]]; then
          COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
          return 0
        fi

        if [[ $COMP_CWORD -eq 2 && ( $prev == on || $prev == off || $prev == up || $prev == down ) ]]; then
          vpn_names=$(find /etc/wireguard -maxdepth 1 -name '*.conf' -exec basename {} .conf \;)
          # Fuzzy match: case-insensitive substring match
          matches=$(printf '%s\n' $vpn_names | grep -i -- "$cur")
          COMPREPLY=( $(compgen -W "$matches") )
          return 0
        fi
      }

      complete -F _vpn_completions vpn
    '';
  };
}
